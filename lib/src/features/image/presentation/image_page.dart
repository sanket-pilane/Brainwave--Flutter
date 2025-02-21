import 'dart:io';

import 'package:brainwave/src/components/loading.dart';
import 'package:brainwave/src/constants/assets.dart';
import 'package:brainwave/src/features/image/bloc/image_bloc.dart';
import 'package:brainwave/src/features/image/domain/model/image_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  TextEditingController controller = TextEditingController();
  final ImageBloc imageBloc = ImageBloc();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final Map<int, String> _finalizedMessages = {};

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

  Future<void> downloadImage(String imageUrl) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Permission denied "),
          ),
        );
        return;
      }

      // Get device's downloads directory

      String downloadPath;
      if (Platform.isAndroid) {
        // For Android 10 (API 29) and above
        downloadPath = '/storage/emulated/0/Download'; // Direct Downloads path
      } else if (Platform.isIOS) {
        // For iOS, saving in app's documents or use a share sheet
        downloadPath = (await getApplicationDocumentsDirectory()).path;
      } else {
        // Handle other platforms if necessary
        downloadPath = '/path/to/your/target/directory';
      }

      String filePath = '$downloadPath/image.jpg';
      Dio dio = Dio();
      await dio.download(imageUrl, filePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image downloaded $filePath"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Download failed: $e"),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus(); // Automatically focus the text field
    });
  }

  @override
  void dispose() {
    // Dispose of all active controllers

    imageBloc.close();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ImageBloc, ImageState>(
        bloc: imageBloc,
        listener: (context, state) {},
        builder: (context, state) {
          switch (state.runtimeType) {
            case ImageSuccessState:
              List<ImageModel> messages = (state as ImageSuccessState).messages;

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

                              return Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 2),
                                  padding: isUser
                                      ? const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 6)
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
                                              message.text,
                                              style: GoogleFonts.lato(
                                                fontWeight: isUser
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                                fontSize: isUser ? 16 : 14,
                                              ),
                                            )
                                          : _finalizedMessages
                                                  .containsKey(index)
                                              ? Column(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.download,
                                                          color: Colors.white),
                                                      onPressed: () =>
                                                          downloadImage(
                                                              message.text),
                                                    ),
                                                    Image.network(
                                                      _finalizedMessages[
                                                          index]!,
                                                      loadingBuilder: (context,
                                                          child,
                                                          loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) return child;
                                                        return Center(
                                                          child: LoadingPage(),
                                                        );
                                                      },
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          const Text(
                                                              "Failed to load image"),
                                                    ),
                                                  ],
                                                )
                                              : Stack(
                                                  children: [
                                                    Image.network(
                                                      message.text,
                                                      loadingBuilder: (context,
                                                          child,
                                                          loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) return child;
                                                        return Center(
                                                          child: LoadingPage(),
                                                        );
                                                      },
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          const Text(
                                                              "Failed to load image"),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4.0,
                                                          vertical: 4),
                                                      child: Container(
                                                        width: 40,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.5)),
                                                        child: IconButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          icon: Icon(
                                                              size: 20,
                                                              Icons.download,
                                                              color:
                                                                  Colors.white),
                                                          onPressed: () =>
                                                              downloadImage(
                                                                  message.text),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Fixed TextField at the bottom
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.grey.shade600,
                          )),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            kBrainwave,
                            width: 30,
                          ),
                          Expanded(
                            child: TextField(
                              focusNode: _focusNode,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              maxLines: null,
                              cursorColor: Colors.grey,
                              controller: controller,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                hintText: "Ask Gemini",
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
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
                                setState(() {
                                  _finalizedMessages[
                                      _finalizedMessages.length] = 'loading';
                                });
                                imageBloc
                                    .add(ImageGeneratedEvent(prompt: text));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );

            default:
              return const Text("Hello ");
          }
        },
      ),
    );
  }
}
