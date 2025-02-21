import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/htmlbars.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/cmake.dart';
import 'package:flutter_highlight/themes/tomorrow-night.dart';

class CodeBlock extends StatelessWidget {
  final String text;

  const CodeBlock({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // Define the mapping between the languages and the highlight modes
    Map<String, dynamic> languageModes = {
      'java': java,
      'cpp': cpp,
      'html': htmlbars,
      'javascript': javascript,
      'python': python,
      'c': cmake,
    };

    // Extract the language and code from the markdown code block
    String extractCode(String markdown) {
      RegExp regex = RegExp(r'```(\w+)\n([\s\S]+?)\n```');
      var match = regex.firstMatch(markdown);
      if (match != null) {
        return match.group(2)?.trim() ?? ''; // Extract the code block content
      } else {
        return ''; // Return empty string if no match
      }
    }

    // Extracted code from the input text
    String extractedCode = extractCode(text);

    // Extract language and use it to select the appropriate syntax highlighter
    String extractLanguage(String markdown) {
      RegExp regex = RegExp(r'```(\w+)\n');
      var match = regex.firstMatch(markdown);
      if (match != null) {
        return match.group(1)?.toLowerCase() ?? 'unknown';
      } else {
        return 'unknown';
      }
    }

    // Extracted language from the markdown
    String extractedLanguage = extractLanguage(text);

    // Check if the extracted language exists in our map
    var language = languageModes[extractedLanguage] ??
        java; // Default to java if not found

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          color: Colors.grey.shade800,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  extractedLanguage.toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: extractedCode))
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Code copied to clipboard!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        CodeTheme(
          data: CodeThemeData(styles: tomorrowNightTheme),
          child: CodeField(
            enabled: true,
            readOnly: true,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionColor: Colors.grey.shade600,
            ),
            textStyle: TextStyle(fontSize: 12),
            controller: CodeController(
              language: language, // Syntax highlighting based on language
              analyzer: DefaultLocalAnalyzer(),
              text: extractedCode, // Pass the extracted code without markdown
            ),
          ),
        ),
      ],
    );
  }
}
