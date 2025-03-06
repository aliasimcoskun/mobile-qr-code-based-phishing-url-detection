// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../services/model_inference.dart';
import '../services/feature_extraction.dart'; // extractFeatures method

/*
 * HomeScreen class
 * 
 * This class represents the home screen of the application.
 * It contains a text field for entering a URL and a button to analyze it.
 * The URL is passed to the feature extraction and model inference services.
 * The result is displayed on the screen.
 * 
 */
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/*
 * _HomeScreenState class
 * 
 * This class represents the state of the HomeScreen widget.
 * It contains the logic for analyzing the URL and displaying the result.
 * 
 */
class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String result = "";

  /*
   * _analyzeUrl method
   * 
   * This method is called when the user clicks the "Analyze" button.
   * It extracts features from the URL and performs inference using the model.
   * The result is displayed on the screen.
   * 
   */
  Future<void> _analyzeUrl() async {
    final url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() {
        result = "Please enter a URL.";
      });
      return;
    }

    // Feature extraction
    List<double> feats = extractFeatures(url);
    // TFLite inference
    double prob = await ModelInference.instance.predictUrlFeatures(feats);
    int label = prob >= 0.5 ? 1 : 0;
    setState(() {
      result = "Probability: $prob => ${label == 1 ? 'Phishing' : 'Safe'}";
    });
  }

  /*
   * build method
   * 
   * This method builds the UI of the HomeScreen widget.
   * It contains a text field, a button, and a text widget for displaying the result.
   * 
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("URL Analyzer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Enter URL...",
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _analyzeUrl,
              child: const Text("Analyze"),
            ),
            const SizedBox(height: 16),
            Text(result),
          ],
        ),
      ),
    );
  }
}
