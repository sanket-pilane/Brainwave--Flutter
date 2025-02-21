import 'dart:async';

import 'package:brainwave/src/constants/assets.dart';

import 'package:brainwave/src/features/code/bloc/code_bloc.dart';

import 'package:brainwave/src/features/code/domain/model/code_model.dart';
import 'package:brainwave/src/features/code/presentation/components/code_block.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CodePage extends StatefulWidget {
  const CodePage({super.key});

  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  TextEditingController controller = TextEditingController();
  final CodeBloc codeBloc = CodeBloc();
  final ScrollController _scrollController = ScrollController();

  // Map to manage streams for each message by ID
  final Map<int, StreamController<String>> _streamControllers = {};
  final Map<int, String> _finalizedMessages = {}; // Finalized responses

  void _startStream(int messageId, String _response) {
    // Skip if the message is already finalized
    if (_finalizedMessages.containsKey(messageId)) return;

    // Ensure we don't recreate the StreamController if it already exists
    if (!_streamControllers.containsKey(messageId)) {
      _streamControllers[messageId] = StreamController<String>.broadcast();
    }

    StreamController<String> controller = _streamControllers[messageId]!;

    Future.delayed(Duration.zero, () async {
      for (int i = 0; i < _response.length; i++) {
        await Future.delayed(const Duration(milliseconds: 10)); // Typing effect
        controller.add(_response.substring(0, i + 1));
      }
      controller.close(); // Close the stream when done
      _finalizedMessages[messageId] = _response;
      _scrollToBottom(); // Save the final content
    });
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // Dispose of all active controllers
    for (var controller in _streamControllers.values) {
      controller.close();
    }
    codeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CodeBloc, CodeState>(
        bloc: codeBloc,
        listener: (context, state) {},
        builder: (context, state) {
          switch (state.runtimeType) {
            case CodeSuccesState:
              List<CodeModel> messages = (state as CodeSuccesState).messages;
              _scrollToBottom();
              return Column(
                children: [
                  // Expanded ListView for the main content
                  Expanded(
                    child: messages.isEmpty
                        ? Center(
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Colors.blue,
                                  Colors.purple,
                                  Colors.pink
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                "Hello, Sir",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isUser = message.role == 'user';

                              // Start streaming for new messages
                              if (!_finalizedMessages.containsKey(index)) {
                                _startStream(index, message.parts.first.text);
                              }

                              return Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 2),
                                    padding: isUser
                                        ? const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10)
                                        : const EdgeInsets.symmetric(
                                            horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? const Color.fromARGB(
                                              255, 60, 101, 124)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.only(
                                        topLeft: isUser
                                            ? const Radius.circular(30)
                                            : Radius.zero,
                                        topRight: isUser
                                            ? Radius.zero
                                            : const Radius.circular(30),
                                        bottomLeft: const Radius.circular(30),
                                        bottomRight: const Radius.circular(30),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Show icon for bot messages
                                        if (!isUser)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: SvgPicture.asset(
                                              kBrainwave, // Path to your SVG file in assets
                                              height: 30,
                                              width: 30,
                                            ),
                                          ),

                                        // Display finalized messages or stream new ones
                                        isUser
                                            ? Text(
                                                message.parts.first.text,
                                                style: GoogleFonts.lato(
                                                  fontWeight: isUser
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                                  fontSize: isUser ? 14 : 12,
                                                ),
                                              )
                                            : _finalizedMessages
                                                    .containsKey(index)
                                                ? CodeBlock(
                                                    text: _finalizedMessages[
                                                        index]!)
                                                : StreamBuilder<String>(
                                                    stream: _streamControllers[
                                                            index]
                                                        ?.stream,
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const Text(
                                                            "Loading...");
                                                      } else if (snapshot
                                                          .hasData) {
                                                        return CodeBlock(
                                                            text:
                                                                snapshot.data!);
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Text(
                                                            "Error: ${snapshot.error}");
                                                      } else {
                                                        return const Text(
                                                            "Done!");
                                                      }
                                                    },
                                                  ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Fixed TextField at the bottom
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.black,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: "Ask Gemini",
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[900],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              String text = controller.text;
                              controller.clear();
                              codeBloc.add(CodeGenerateNewTextMessageEvent(
                                  prompt: text));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );

            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
