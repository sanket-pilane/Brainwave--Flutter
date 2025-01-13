import 'package:brainwave/src/features/code/bloc/chat_bloc.dart';

import 'package:flutter/material.dart';

class CodePage extends StatefulWidget {
  const CodePage({super.key});

  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  TextEditingController controller = TextEditingController();
  final ChatBloc chatBloc = ChatBloc();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Expanded ListView for the main content
          Expanded(
            child: ListView.builder(
              itemCount: 20, // Example list item count
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    "Item $index",
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Description of item",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
          ),

          // Fixed TextField at the bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
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
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
