import 'dart:async';
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
import 'package:lottie/lottie.dart';
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

  // Map to track loading state
  final Map<int, bool> _isLoading = {};
  // Map to track generation progress
  final Map<int, double> _generationProgress = {};
  // Map to track if we're in the loading animation phase
  final Map<int, bool> _showLoadingAnimation = {};

  // Define a constant for the loading animation asset
  // Update this path

  // Generation time in seconds
  final int generationTimeInSeconds = 6; // 6 seconds as requested

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

  // Function to simulate image generation with a progress bar
  void _simulateImageGeneration(int index, String imageUrl) {
    // Initialize progress to 0
    setState(() {
      _showLoadingAnimation[index] = true;
      _generationProgress[index] = 0.0;
      _finalizedMessages[index] = imageUrl;
    });

    // Create a timer that updates progress every 100ms for smoother progress bar
    int elapsedMilliseconds = 0;
    int totalMilliseconds = generationTimeInSeconds * 1000;
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      elapsedMilliseconds += 100;
      double progress = elapsedMilliseconds / totalMilliseconds;

      // Update progress state
      setState(() {
        _generationProgress[index] = progress > 1.0 ? 1.0 : progress;
      });

      // When time is up, cancel timer and show the image
      if (elapsedMilliseconds >= totalMilliseconds) {
        timer.cancel();
        setState(() {
          _showLoadingAnimation[index] = false;
        });
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

      // Generate a file name based on timestamp
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileExtension = imageUrl.split('.').last.split('?').first;
      if (fileExtension.length > 5)
        fileExtension = 'jpg'; // Default to jpg if extension is weird

      String filePath = '$downloadPath/image_$timestamp.$fileExtension';

      Dio dio = Dio();
      await dio.download(imageUrl, filePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image downloaded to $filePath"),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Download failed: $e"),
          duration: Duration(seconds: 3),
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
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ImageBloc, ImageState>(
        bloc: imageBloc,
        listener: (context, state) {
          if (state is ImageSuccessState) {
            List<ImageModel> messages = state.messages;

            // Find the last non-user message that might need processing
            for (int i = 0; i < messages.length; i++) {
              final message = messages[i];
              if (message.role != 'user' &&
                  !_finalizedMessages.containsKey(i)) {
                // Start the loading animation for this new image
                _simulateImageGeneration(i, message.text);
              }
            }
            _scrollToBottom();
          }
        },
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

                                      // Display user messages or images with proper loading state
                                      isUser
                                          ? Text(
                                              message.text,
                                              style: GoogleFonts.lato(
                                                fontWeight: isUser
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                                fontSize: isUser ? 16 : 14,
                                                color: Colors.white,
                                              ),
                                            )
                                          : _finalizedMessages
                                                      .containsKey(index) &&
                                                  (_showLoadingAnimation[
                                                          index] ??
                                                      false)
                                              ? _buildLoadingAnimation(index)
                                              : _finalizedMessages
                                                      .containsKey(index)
                                                  ? Column(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Image.network(
                                                              _finalizedMessages[
                                                                  index]!,
                                                              loadingBuilder:
                                                                  (context,
                                                                      child,
                                                                      loadingProgress) {
                                                                if (loadingProgress ==
                                                                    null)
                                                                  return child;
                                                                return Center(
                                                                  child:
                                                                      LoadingPage(),
                                                                );
                                                              },
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  const Text(
                                                                      "Failed to load image",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)),
                                                            ),
                                                            Positioned(
                                                              top: 8,
                                                              right: 8,
                                                              child: Container(
                                                                width: 36,
                                                                height: 36,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.6),
                                                                ),
                                                                child:
                                                                    IconButton(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  icon: Icon(
                                                                    Icons
                                                                        .download,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 20,
                                                                  ),
                                                                  onPressed: () =>
                                                                      downloadImage(
                                                                          _finalizedMessages[
                                                                              index]!),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )
                                                  : Center(
                                                      child: LoadingPage(),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 12.0),
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
                                hintText: "Ask Brainwave",
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
                                FocusScope.of(context).unfocus();
                                String text = controller.text;
                                controller.clear();
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
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // New method to build the loading animation with progress bar
  Widget _buildLoadingAnimation(int index) {
    final progress = _generationProgress[index] ?? 0.0;
    final percentComplete = (progress * 100).toInt();

    return Container(
      width: 240,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lottie animation
          SizedBox(
            height: 120,
            width: 120,
            child: Lottie.asset(
              loadingAnimation2,
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(height: 16),

          // Text showing what's happening
          Text(
            "Generating your image...",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          SizedBox(height: 12),

          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),

          SizedBox(height: 8),

          // Percentage text
          Text(
            "$percentComplete% complete",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          SizedBox(height: 8),

          // Estimated time remaining
          Text(
            "Estimated time remaining: ${_formatRemainingTime(progress)}",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format remaining time
  String _formatRemainingTime(double progress) {
    if (progress >= 1.0) return "Complete";

    final remainingSeconds =
        (generationTimeInSeconds * (1.0 - progress)).toInt();
    if (remainingSeconds < 1) return "Less than 1 second";

    return "$remainingSeconds seconds";
  }
}
