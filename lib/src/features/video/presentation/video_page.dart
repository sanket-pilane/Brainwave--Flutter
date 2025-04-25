import 'dart:async';
import 'dart:io';
import 'package:brainwave/src/components/loading.dart';
import 'package:brainwave/src/constants/assets.dart';
import 'package:brainwave/src/features/video/bloc/video_bloc.dart';
import 'package:brainwave/src/features/video/bloc/video_state.dart';
import 'package:brainwave/src/features/video/domain/model/video_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  TextEditingController controller = TextEditingController();
  final VideoBloc videoBloc = VideoBloc();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final Map<int, String> _finalizedMessages = {};
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, bool> _isPlaying = {};
  // Map to track loading state
  final Map<int, bool> _isLoading = {};
  // Map to track error state
  final Map<int, bool> _hasError = {};
  // Map to track generation progress
  final Map<int, double> _generationProgress = {};
  // Map to track if we're in the loading animation phase
  final Map<int, bool> _showLoadingAnimation = {};

  // Define a constant for the loading animation asset

  // Generation time in seconds (2m36s = 156s)
  final int generationTimeInSeconds = 210;

  // Test URL for development
  final String testVideoUrl =
      "https://replicate.delivery/czjl/0BRwO64eE5xCNCunM61wjfjaozXEm6ee2fpbldrwj6fxxVO9E/tmpxql776w8.output.mp4";

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

  Future<void> _initializeVideoController(int index, String videoUrl) async {
    // Set loading state to true for this index
    setState(() {
      _isLoading[index] = true;
      _hasError[index] = false;
    });

    // Dispose existing controller if any
    if (_videoControllers.containsKey(index)) {
      await _videoControllers[index]!.dispose();
      _videoControllers.remove(index);
    }

    try {
      // Create and initialize the controller
      final controller = VideoPlayerController.network(videoUrl);
      _videoControllers[index] = controller;

      // Add listener to handle state updates
      controller.addListener(() {
        if (mounted) setState(() {});
      });

      // Initialize the controller
      await controller.initialize();
      _isPlaying[index] = false;

      // Update UI and set loading to false only if widget is still mounted
      if (mounted) {
        setState(() {
          _isLoading[index] = false;
        });
      }
    } catch (e) {
      print("Error initializing video controller: $e");
      // Mark as failed in UI
      if (mounted) {
        setState(() {
          _isLoading[index] = false;
          _hasError[index] = true;
        });
      }
    }
  }

  // Function to simulate video generation with a progress bar
  void _simulateVideoGeneration(int index) {
    // Initialize progress to 0
    setState(() {
      _showLoadingAnimation[index] = true;
      _generationProgress[index] = 0.0;
    });

    // Create a timer that updates progress every second
    int elapsedSeconds = 0;
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      elapsedSeconds++;
      double progress = elapsedSeconds / generationTimeInSeconds;

      // Update progress state
      setState(() {
        _generationProgress[index] = progress > 1.0 ? 1.0 : progress;
      });

      // When time is up, cancel timer and initialize the video player
      if (elapsedSeconds >= generationTimeInSeconds) {
        timer.cancel();
        setState(() {
          _showLoadingAnimation[index] = false;
        });
        if (_finalizedMessages.containsKey(index)) {
          _initializeVideoController(index, _finalizedMessages[index]!);
        }
      }
    });
  }

  void _playPause(int index) {
    final controller = _videoControllers[index];
    if (controller != null) {
      if (controller.value.isPlaying) {
        controller.pause();
        setState(() {
          _isPlaying[index] = false;
        });
      } else {
        // Pause all other videos first
        _videoControllers.forEach((idx, ctrl) {
          if (idx != index && ctrl.value.isPlaying) {
            ctrl.pause();
            _isPlaying[idx] = false;
          }
        });

        // Play this video
        controller.play();
        setState(() {
          _isPlaying[index] = true;
        });
      }
    }
  }

  Future<void> downloadVideo(String videoUrl) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Permission denied"),
          ),
        );
        return;
      }

      // Show download started message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Download started..."),
        ),
      );

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
      String fileExtension = videoUrl.split('.').last.split('?').first;
      if (fileExtension.length > 5)
        fileExtension = 'mp4'; // Default to mp4 if extension is weird

      String filePath = '$downloadPath/video_$timestamp.$fileExtension';

      Dio dio = Dio();
      await dio.download(videoUrl, filePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          // Update progress if we want to add a progress indicator later
          int progress = (received / total * 100).toInt();
          print("Download progress: $progress%");
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Video downloaded to $filePath"),
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

    // For testing - add a fake message with the test video URL

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus(); // Automatically focus the text field
    });
  }

  @override
  void dispose() {
    // Dispose of all video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();

    videoBloc.close();
    _focusNode.dispose();
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<VideoBloc, VideoState>(
        bloc: videoBloc,
        listener: (context, state) {
          if (state is VideoSuccessState) {
            // Initialize video controllers for any new messages
            for (int i = 0; i < state.messages.length; i++) {
              final message = state.messages[i];
              if (message.role != 'user' &&
                  !_finalizedMessages.containsKey(i)) {
                // For testing, use the test URL
                final videoUrl =
                    message.text; // Use message.text for production
                _finalizedMessages[i] = videoUrl;

                // Start the loading animation and progress bar instead of immediately initializing the video
                _simulateVideoGeneration(i);
              }
            }
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case VideoSuccessState:
              List<VideoModel> messages = (state as VideoSuccessState).messages;

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
                                      vertical: 10, horizontal: 8),
                                  padding: isUser
                                      ? const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12)
                                      : const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
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

                                      // Display user messages or videos
                                      if (isUser)
                                        Text(
                                          message.text,
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        )
                                      else if (_finalizedMessages
                                              .containsKey(index) &&
                                          (_showLoadingAnimation[index] ??
                                              false))
                                        _buildLoadingAnimation(index)
                                      else if (_finalizedMessages
                                              .containsKey(index) &&
                                          !(_isLoading[index] ?? true))
                                        _buildVideoPlayer(
                                            index, _finalizedMessages[index]!)
                                      else
                                        Center(
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
                        ),
                      ),
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
                                videoBloc
                                    .add(VideoGeneratedEvent(prompt: text));
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
      width: 260,
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
            height: 150,
            width: 150,
            child: Lottie.asset(
              loadingAnimation2,
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(height: 16),

          // Text showing what's happening
          Text(
            "Generating your video...",
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
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  Widget _buildVideoPlayer(int index, String videoUrl) {
    final controller = _videoControllers[index];
    final isPlaying = _isPlaying[index];
    final hasError = _hasError[index] ?? false;

    // If there's an error after loading attempt
    if (hasError) {
      return Center(
        child: Container(
          width: 200,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.red, size: 40),
              SizedBox(height: 8),
              Text(
                "Video failed to load",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _initializeVideoController(index, videoUrl),
                child: Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // If controller is null or we're still initializing
    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: LoadingPage(),
      );
    }

    // Actual video player
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Video player
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),

              // Play/pause button overlay
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _playPause(index),
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: controller.value.isPlaying ? 0.0 : 0.7,
                        duration: Duration(milliseconds: 300),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Download button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.download,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => downloadVideo(videoUrl),
                  ),
                ),
              ),
            ],
          ),

          // Video controls
          Container(
            color: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Row(
              children: [
                // Play/pause button
                IconButton(
                  icon: Icon(
                    controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () => _playPause(index),
                ),

                // Progress bar
                Expanded(
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Colors.red,
                      bufferedColor: Colors.grey.shade400,
                      backgroundColor: Colors.grey.shade800,
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  ),
                ),

                // Video duration
                Text(
                  _formatDuration(controller.value.position) +
                      ' / ' +
                      _formatDuration(controller.value.duration),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

// Custom loading widget
class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "Loading video...",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
