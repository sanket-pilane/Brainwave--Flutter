import 'dart:io';
import 'package:brainwave/src/components/loading.dart';
import 'package:brainwave/src/constants/assets.dart';
import 'package:brainwave/src/features/audio/bloc/audio_bloc.dart';
import 'package:brainwave/src/features/audio/domain/model/audio_model.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart'; // Replace video_player with just_audio
import 'package:audio_session/audio_session.dart'; // For managing audio sessions

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  TextEditingController controller = TextEditingController();
  final AudioBloc audioBloc = AudioBloc();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final Map<int, String> _finalizedMessages = {};
  final Map<int, AudioPlayer> _audioPlayers =
      {}; // Audio players instead of video controllers
  final Map<int, bool> _isPlaying = {};
  final Map<int, bool> _isLoading = {};
  final Map<int, bool> _hasError = {};
  final Map<int, Duration> _currentPositions =
      {}; // Track current audio positions
  final Map<int, Duration> _totalDurations = {}; // Track total audio durations

  // Test URL for development
  final String testAudioUrl =
      "https://replicate.delivery/pbxt/SCiO1SBkqj7gL5cTsq8AXz5pIwPajeiWbb9s17KtyQ2G3OFIA/gen_sound.wav";

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

  Future<void> _initializeAudioPlayer(int index, String audioUrl) async {
    // Set loading state to true for this index
    setState(() {
      _isLoading[index] = true;
      _hasError[index] = false;
    });

    // Dispose existing player if any
    if (_audioPlayers.containsKey(index)) {
      await _audioPlayers[index]!.dispose();
      _audioPlayers.remove(index);
    }

    try {
      // Configure audio session for better audio handling
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.speech());

      // Create new audio player
      final player = AudioPlayer();
      _audioPlayers[index] = player;

      // Listen for position updates
      player.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _currentPositions[index] = position;
          });
        }
      });

      // Listen for duration updates
      player.durationStream.listen((duration) {
        if (mounted && duration != null) {
          setState(() {
            _totalDurations[index] = duration;
          });
        }
      });

      // Listen for player state changes
      player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying[index] = state.playing;

            // Handle audio completion
            if (state.processingState == ProcessingState.completed) {
              _isPlaying[index] = false;
              player.seek(Duration.zero);
            }
          });
        }
      });

      // Set the audio source and prepare it
      await player.setUrl(audioUrl);
      await player.setVolume(1.0);

      // Set initial states
      _isPlaying[index] = false;
      _currentPositions[index] = Duration.zero;

      if (mounted) {
        setState(() {
          _isLoading[index] = false;
        });
      }
    } catch (e) {
      print("Error initializing audio player: $e");
      // Mark as failed in UI
      if (mounted) {
        setState(() {
          _isLoading[index] = false;
          _hasError[index] = true;
        });
      }
    }
  }

  void _playPause(int index) {
    final player = _audioPlayers[index];
    if (player != null) {
      if (player.playing) {
        player.pause();
      } else {
        // Pause all other audio players first
        _audioPlayers.forEach((idx, plyr) {
          if (idx != index && plyr.playing) {
            plyr.pause();
            _isPlaying[idx] = false;
          }
        });

        // Play this audio
        player.play();
      }
    }
  }

  Future<void> _seekTo(int index, Duration position) async {
    final player = _audioPlayers[index];
    if (player != null) {
      await player.seek(position);
    }
  }

  Future<void> downloadAudio(String audioUrl) async {
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
      String fileExtension = audioUrl.split('.').last.split('?').first;
      if (fileExtension.length > 5)
        fileExtension = 'mp3'; // Default to mp3 if extension is weird

      String filePath = '$downloadPath/Audio_$timestamp.$fileExtension';

      Dio dio = Dio();
      await dio.download(audioUrl, filePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          // Update progress if we want to add a progress indicator later
          int progress = (received / total * 100).toInt();
          print("Download progress: $progress%");
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Audio downloaded to $filePath"),
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
    // Dispose of all audio players
    for (var player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();

    audioBloc.close();
    _focusNode.dispose();
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AudioBloc, AudioState>(
        bloc: audioBloc,
        listener: (context, state) {
          if (state is AudioSuccessState) {
            // Initialize audio players for any new messages
            for (int i = 0; i < state.messages.length; i++) {
              final message = state.messages[i];
              if (message.role != 'user' &&
                  !_finalizedMessages.containsKey(i)) {
                // For testing, use the test URL
                final audioUrl =
                    message.text; // Use the message text as audio URL
                _finalizedMessages[i] = audioUrl;
                _initializeAudioPlayer(i, audioUrl);
              }
            }
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case AudioSuccessState:
              List<AudioModel> messages = (state as AudioSuccessState).messages;

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

                                      // Display user messages or Audios
                                      if (isUser)
                                        Text(
                                          message.text,
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        )
                                      else if (!isUser &&
                                          !_finalizedMessages
                                              .containsKey(index))
                                        Center(
                                          child: Lottie.asset(loadingAnimation),
                                        )
                                      else if (_finalizedMessages
                                              .containsKey(index) &&
                                          !(_isLoading[index] ?? true))
                                        _buildAudioPlayer(
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
                                audioBloc
                                    .add(AudioGeneratedEvent(prompt: text));
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

  Widget _buildAudioPlayer(int index, String audioUrl) {
    final player = _audioPlayers[index];
    final hasError = _hasError[index] ?? false;
    final isPlaying = _isPlaying[index] ?? false;
    final currentPosition = _currentPositions[index] ?? Duration.zero;
    final totalDuration = _totalDurations[index] ?? Duration.zero;

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
                "Audio failed to load",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _initializeAudioPlayer(index, audioUrl),
                child: Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // If player is null or we're still initializing
    if (player == null || (_isLoading[index] ?? true)) {
      return Center(
        child: LoadingPage(),
      );
    }

    // Calculate progress percentage for the circular progress indicator
    double progress = 0.0;
    if (totalDuration.inMilliseconds > 0) {
      progress = currentPosition.inMilliseconds / totalDuration.inMilliseconds;
    }

    // Actual Audio player
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
        minWidth: 200,
      ),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Audio visualization and controls
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Play/pause button with circular progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Circular progress indicator
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade700,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    // Play/pause icon
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => _playPause(index),
                    ),
                  ],
                ),

                SizedBox(width: 12),

                // Audio visualization (simplified)
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomPaint(
                        painter: AudioWaveformPainter(
                          progress: progress,
                          isPlaying: isPlaying,
                        ),
                        size: Size.fromHeight(40),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 8),

                // Download button
                Container(
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
                    onPressed: () => downloadAudio(audioUrl),
                  ),
                ),
              ],
            ),
          ),

          // Progress slider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: Colors.blue,
                inactiveTrackColor: Colors.grey.shade600,
                thumbColor: Colors.white,
                overlayColor: Colors.blue.withOpacity(0.3),
              ),
              child: Slider(
                value: currentPosition.inMilliseconds.toDouble(),
                min: 0,
                max: totalDuration.inMilliseconds.toDouble(),
                onChanged: (value) {
                  // Update UI immediately for smoother feel
                  setState(() {
                    _currentPositions[index] =
                        Duration(milliseconds: value.toInt());
                  });
                },
                onChangeEnd: (value) {
                  // Actually seek the audio when user releases slider
                  _seekTo(index, Duration(milliseconds: value.toInt()));
                },
              ),
            ),
          ),

          // Time indicators
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(currentPosition),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(totalDuration),
                  style: TextStyle(
                    color: Colors.white70,
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

// Custom painter for audio waveform visualization
class AudioWaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;

  AudioWaveformPainter({
    required this.progress,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a simplified audio waveform visualization
    final Paint activePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final Paint inactivePaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;

    // Generate some random bar heights for visualization
    final random = List.generate(
        60,
        (i) => (0.3 +
            0.7 *
                (i % 3 == 0
                    ? 0.8
                    : i % 5 == 0
                        ? 0.6
                        : 0.4)));

    // Draw the waveform bars
    final double barWidth = width / random.length;
    final double activeWidth = width * progress;

    for (int i = 0; i < random.length; i++) {
      final double barHeight = random[i] * height;
      final double startX = i * barWidth;
      final double barXCenter = startX + barWidth / 2;

      // Determine if this bar is in the active (played) region
      final Paint paint = startX < activeWidth ? activePaint : inactivePaint;

      // Add pulsing effect if playing
      double heightMultiplier = 1.0;
      if (isPlaying && startX < activeWidth) {
        // Make some bars "pulse" when playing
        if (i % 4 == 0) {
          heightMultiplier = 1.2;
        } else if (i % 3 == 0) {
          heightMultiplier = 0.9;
        }
      }

      final double actualBarHeight = barHeight * heightMultiplier;
      final double top = (height - actualBarHeight) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            startX,
            top,
            barWidth * 0.6, // Make bars a bit narrower than their slots
            actualBarHeight,
          ),
          Radius.circular(barWidth * 0.3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isPlaying != isPlaying;
  }
}

// Custom loading widget
class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 100,
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
              "Loading Audio...",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
