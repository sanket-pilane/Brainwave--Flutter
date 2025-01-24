import 'package:brainwave/src/constants/assets.dart';
import 'package:brainwave/src/constants/colors.dart';
import 'package:brainwave/src/features/code/bloc/chat_bloc.dart';
import 'package:brainwave/src/features/code/domain/model/chat_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController controller = TextEditingController();
  final ChatBloc chatBloc = ChatBloc();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ChatBloc, ChatState>(
        bloc: chatBloc,
        listener: (context, state) {},
        builder: (context, state) {
          switch (state.runtimeType) {
            case ChatSuccesState:
              List<ChatModel> messages = (state as ChatSuccesState).messages;

              return Column(
                children: [
                  // Expanded ListView for the main content
                  Expanded(
                    child: messages.isEmpty
                        ? Center(
                            child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.blue, Colors.purple, Colors.pink],
                            ).createShader(bounds),
                            child: const Text(
                              "Hello, Sanket",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ))
                        : ListView.builder(
                            itemCount:
                                messages.length, // Example list item count
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isUser = message.role == 'user';
                              return Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 2),
                                  padding: isUser
                                      ? EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 6)
                                      : EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? Colors
                                            .blueGrey[900] // User message color
                                        : AppColors
                                            .sideNav, // Model message color
                                    borderRadius: BorderRadius.only(
                                      topLeft: isUser
                                          ? Radius.circular(30)
                                          : Radius.zero,
                                      topRight: isUser
                                          ? Radius.zero
                                          : Radius.circular(30),
                                      bottomLeft: isUser
                                          ? Radius.circular(30)
                                          : Radius.circular(30),
                                      bottomRight: isUser
                                          ? Radius.circular(30)
                                          : Radius.circular(30),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      isUser
                                          ? SizedBox()
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: SvgPicture.asset(
                                                kBrainwave, // Path to your SVG file in assets
                                                height: 30, // Set height
                                                width: 30, // Set width
                                                // Optional: Apply a color filter
                                              ),
                                            ),
                                      Text(message.parts.first.text,
                                          style: GoogleFonts.lato(
                                            fontWeight: isUser
                                                ? FontWeight.bold
                                                : FontWeight.w400,
                                            fontSize: isUser ? 16 : 14,
                                          ))
                                    ],
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
                            style: TextStyle(
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
                              chatBloc.add(ChatGenerateNewTextMessageEvent(
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
              return SizedBox();
          }
        },
      ),
    );
  }
}
