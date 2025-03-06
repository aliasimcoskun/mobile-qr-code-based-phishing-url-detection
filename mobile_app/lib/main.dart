// lib/main.dart

import 'package:flutter/material.dart';
import 'services/model_inference.dart';
import 'services/feature_extraction.dart';
import 'services/url_expander.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

/*
 * main function
 * 
 * The entry point of the application. It initializes the app and runs the main
 * event loop to listen for events and update the UI.
 * 
 */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Perform an initial test by loading and testing the model
  double testVal = await ModelInference.instance.predictUrlFeatures([
    10.0, // domain_length
    0.0, // have_ip
    0.0, // have_at
    22.0, // url_length
    2.0, // url_depth
    0.0, // redirection
    1.0, // https_domain
    0.0, // tiny_url
    0.0, // prefix_suffix
  ]);
  print("[DEBUG] dummyPredict => $testVal");

  runApp(const MyApp());
}

/*
 * MyApp class
 * 
 * This class represents the root of the application. It creates a MaterialApp
 * widget to provide the basic visual structure for the app, including the title,
 * theme, and initial screen.
 * 
 */
class MyApp extends StatelessWidget {
  // Constructor for MyApp, accepting a key
  const MyApp({super.key});

  /*
    * build method
    * 
    * This method builds the UI of the application using the MaterialApp widget.
    * It provides the basic visual structure for the app, including the title,
    * theme, and initial screen.
    * 
    * Parameters:
    * - context: The build context for the widget
    * 
    * Returns:
    * - MaterialApp widget with the app title, theme, and initial screen
    * 
    */
  @override
  Widget build(BuildContext context) {
    // MaterialApp provides the basic visual structure for the app
    return MaterialApp(
      title: 'Phishing URL Detector', // Title of the application
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        primarySwatch: Colors.orange, // Primary color theme
        scaffoldBackgroundColor:
            Colors.grey[50], // Background color for Scaffold
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, // Button background color
            foregroundColor: Colors.white, // Button text color
            textStyle: const TextStyle(fontSize: 16), // Text style for buttons
            padding: const EdgeInsets.symmetric(
                vertical: 14), // Padding inside buttons
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12), // Rounded corners for buttons
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true, // Fills the input fields with color
          fillColor: Colors.white, // Background color for input fields
          contentPadding: EdgeInsets.symmetric(
              vertical: 16, horizontal: 20), // Padding inside input fields
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(12)), // Rounded borders for input fields
            borderSide: BorderSide.none, // No border side
          ),
          hintStyle: TextStyle(
              color: Colors.grey), // Style for hint text in input fields
        ),
      ),
      home:
          const HomeScreen(), // Sets HomeScreen as the initial screen of the app
    );
  }
}

/*
 * HomeScreen class
 * 
 * This class represents the main screen of the application where users can
 * enter a URL or scan a QR code to analyze for phishing. It provides a text
 * input field, buttons for analysis and scanning, and displays the result.
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
 * This class represents the state of the HomeScreen widget. It manages the
 * state of the URL input field, analysis result, loading state, and handles
 * the navigation to the QR scanning screen. It also contains the logic for
 * analyzing the entered or scanned URL for phishing.
 * 
 */
class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController =
      TextEditingController(); // Controller for the URL input field
  String _result = ""; // Variable to hold the analysis result
  bool _isLoading = false; // Indicator for loading state

  /*
   * _navigateToScanner method
   * 
   * This method navigates to the QRViewExample screen to scan a QR code.
   * It waits for the scanned URL and updates the text field with the scanned URL.
   * 
   */
  void _navigateToScanner() async {
    // Navigate to the QRViewExample screen and wait for the scanned URL
    final scannedUrl = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRViewExample()),
    );

    // If a URL was scanned, update the text field and analyze the URL
    if (scannedUrl != null && scannedUrl is String) {
      _urlController.text = scannedUrl;
      _analyzeUrl(scannedUrl);
    }
  }

  String _lastUrl = ""; // Stores the last URL analyzed
  String _lastLabel = ""; // Stores the last label (Phishing/Safe)

  /*
   * _analyzeUrl method
   * 
   * This method analyzes the URL for phishing by expanding the URL, extracting
   * features, and performing model inference. It updates the result based on
   * the prediction and probability of the model.
   * 
   * Parameters:
   * - url: The URL to analyze for phishing
   * 
   */
  Future<void> _analyzeUrl(String url) async {
    if (url.isEmpty) {
      // If URL is empty, show a message
      setState(() {
        _result = "Please enter a URL.";
      });
      return;
    }

    // Set loading state to true
    setState(() {
      _isLoading = true;
    });

    String finalUrl = url;

    // 1) Expand the URL using UrlExpander service
    String? expandedUrl = await UrlExpander.expandUrl(url);
    if (expandedUrl != null && expandedUrl.isNotEmpty) {
      finalUrl = expandedUrl;
      _urlController.text = finalUrl;
    } else {
      // If URL expansion fails, update the result and stop loading
      setState(() {
        _isLoading = false;
        _result = "URL expansion failed.";
      });
      return;
    }

    // 2) Extract features
    List<double> features = extractFeatures(finalUrl);

    // 3) Model inference
    double prob = await ModelInference.instance.predictUrlFeatures(features);

    // 4) Determine label based on probability
    int label = prob >= 0.5 ? 1 : 0;
    String labelStr = label == 1 ? "Phishing" : "Safe";

    // Update the state with the result and stop loading
    setState(() {
      _isLoading = false;
      _result =
          "Prediction: $labelStr\nProbability: ${prob.toStringAsFixed(4)}";
      _lastUrl = finalUrl;
      _lastLabel = labelStr;
    });
  }

  /*
   * dispose method
   * 
   * This method disposes of the _urlController when the widget is removed.
   * 
   * Note: It is important to dispose of controllers to prevent memory leaks.
   * 
   */
  @override
  void dispose() {
    _urlController.dispose(); // Dispose the controller when widget is removed
    super.dispose();
  }

  /*
   * build method
   * 
   * This method builds the UI of the HomeScreen widget using a Scaffold widget.
   * It includes an app bar, input field, action buttons, loading indicator,
   * result display, and a redirect button. The UI is updated based on the state.
   * 
   * Parameters:
   * - context: The build context for the widget
   * 
   * Returns:
   * - Scaffold widget with the app bar, input field, buttons, and result display
   * 
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "URL Phishing Detector"), // Title displayed in the app bar
        centerTitle: true, // Centers the title in the app bar
        elevation: 0, // Removes the shadow beneath the app bar
        backgroundColor: Colors.orange, // Sets the app bar background color
        actions: [
          IconButton(
            icon: const Icon(
                Icons.info_outline), // Information icon in the app bar
            onPressed: () {
              // Shows an about dialog when the info icon is pressed
              showAboutDialog(
                context: context,
                applicationName:
                    'URL Phishing Detector', // Name of the application
                applicationVersion: '1.0.0', // Version of the application
                applicationIcon:
                    const Icon(Icons.security), // Icon displayed in the dialog
                children: const [
                  Text(
                      "This application detects whether the URLs entered or scanned are phishing.\n\n-Made by Ali Asım Coşkun"), // Description of the application
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.all(24.0), // Adds padding around the content
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Aligns children to the start
            children: [
              // Header Section
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons
                          .security, // Security icon representing the app's purpose
                      color: Colors.indigo, // Icon color
                      size: 80, // Icon size
                    ),
                    const SizedBox(height: 10), // Adds vertical spacing
                    const Text(
                      "Phishing URL Detector", // Header text
                      style: TextStyle(
                        fontSize: 24, // Text size
                        fontWeight: FontWeight.bold, // Text weight
                        color: Colors.indigo, // Text color
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30), // Adds vertical spacing

              // URL Input Field
              const Text(
                "Enter URL or Scan QR Code:", // Instruction text
                style: TextStyle(
                  fontSize: 18, // Text size
                  fontWeight: FontWeight.w600, // Text weight
                ),
              ),
              const SizedBox(height: 10), // Adds vertical spacing
              TextField(
                controller: _urlController, // Controller for the text field
                decoration: const InputDecoration(
                  hintText:
                      "https://www.example.com", // Hint text displayed inside the text field
                ),
              ),
              const SizedBox(height: 20), // Adds vertical spacing

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _analyzeUrl(_urlController.text
                            .trim()); // Calls analyze function with trimmed URL
                      },
                      icon:
                          const Icon(Icons.search), // Search icon on the button
                      label: const Text("Analyze"), // Button label
                    ),
                  ),
                  const SizedBox(width: 16), // Adds horizontal spacing
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _navigateToScanner, // Navigates to the QR scanner
                      icon:
                          const Icon(Icons.qr_code_scanner), // QR scanner icon
                      label: const Text("Scan QR Code"), // Button label
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30), // Adds vertical spacing

              // Loading Indicator
              if (_isLoading)
                const Center(
                  child:
                      CircularProgressIndicator(), // Shows a loading spinner when analyzing
                ),

              // Result Display
              if (_result.isNotEmpty && !_isLoading)
                Center(
                  child: Card(
                    elevation: 4, // Shadow depth of the card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          12), // Rounded corners for the card
                    ),
                    color: labelColor(_result
                        .split('\n')[0]), // Sets card color based on the label
                    child: Padding(
                      padding: const EdgeInsets.all(
                          16.0), // Adds padding inside the card
                      child: Text(
                        _result, // Displays the analysis result
                        style: const TextStyle(
                          fontSize: 18, // Text size
                          color: Colors.white, // Text color
                          fontWeight: FontWeight.w600, // Text weight
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20), // Adds vertical spacing

              // Redirect Button
              if (_lastUrl.isNotEmpty && !_isLoading)
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_lastLabel == "Phishing") {
                        // Shows a warning dialog if the URL is identified as phishing
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Warning"), // Dialog title
                              content: const Text(
                                  "The website you will be redirected to can be malicious. Are you sure?"), // Dialog content
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(
                                      context, false), // Cancels the action
                                  child: const Text("No"), // Button label
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(
                                      context, true), // Confirms the action
                                  child: const Text("Yes"), // Button label
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm == true) {
                          await launchUrl(Uri.parse(
                              _lastUrl)); // Launches the URL if confirmed
                        }
                      } else {
                        await launchUrl(Uri.parse(
                            _lastUrl)); // Launches the URL if not phishing
                      }
                    },
                    child: const Text("Redirect"), // Button label
                  ),
                ),
              if (_result.isEmpty && !_isLoading)
                const Center(
                  child: Text(
                    "Analyze a URL or scan a QR code to get started.", // Prompt text when no analysis has been done
                    style: TextStyle(
                      fontSize: 16, // Text size
                      color: Colors.grey, // Text color
                    ),
                    textAlign: TextAlign.center, // Centers the text
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /*
   * labelColor method
   * 
   * This method returns a color based on the prediction label.
   * 
   * Parameters:
   * - prediction: The prediction label (Phishing/Safe)
   * 
   * Returns:
   * - Color based on the prediction label
   * 
   */
  Color labelColor(String prediction) {
    if (prediction.contains("Phishing")) {
      return Colors.redAccent; // Red color for phishing
    } else if (prediction.contains("Safe")) {
      return Colors.green; // Green color for safe URLs
    } else {
      return Colors.grey; // Grey color for unknown results
    }
  }
}

/*
 * QRViewExample class
 * 
 * This class represents the screen for scanning QR codes. It uses the MobileScanner
 * widget to display the camera view and detect QR codes. The detected QR code
 * is returned to the HomeScreen for analysis.
 * 
 */
class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

/*
 * _QRViewExampleState class
 * 
 * This class represents the state of the QRViewExample widget. It manages the
 * scanner controller, scanning state, and the callback function for barcode
 * detection. It displays the camera view and an overlay to indicate the scanning
 * area.
 * 
 */
class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey =
      GlobalKey(debugLabel: 'QR'); // Unique key for the QR view
  MobileScannerController controller =
      MobileScannerController(); // Controller to manage the scanner
  bool _isScanning = true; // Flag to indicate if scanning is active

  @override
  void dispose() {
    controller
        .dispose(); // Dispose the scanner controller when the widget is removed
    super.dispose();
  }

  /*
   * _foundBarcode method
   * 
   * This method is called when a barcode is detected by the scanner. It extracts
   * the raw value of the barcode and stops further scanning. The scanned code
   * is then returned to the HomeScreen and the scanner is closed.
   * 
   * Parameters:
   * - capture: The BarcodeCapture object containing the detected barcodes
   * 
   */
  void _foundBarcode(BarcodeCapture capture) {
    if (!_isScanning) return; // Exit if scanning has been stopped

    final List<Barcode> barcodes =
        capture.barcodes; // List of detected barcodes
    for (final barcode in barcodes) {
      final String? code =
          barcode.rawValue; // Extract the raw value of the barcode
      if (code != null && _isScanning) {
        _isScanning = false; // Stop further scanning
        controller.stop(); // Stop the scanner

        Navigator.pop(
            context, code); // Return the scanned code and close the scanner
        break; // Exit the loop after processing the first valid code
      }
    }
  }

  /*
   * build method
   * 
   * This method builds the UI of the QRViewExample widget using a Scaffold widget.
   * It includes the MobileScanner widget to display the camera view and detect
   * QR codes. An overlay is added to indicate the scanning area.
   * 
   * Parameters:
   * - context: The build context for the widget
   * 
   * Returns:
   * - Scaffold widget with the camera view and scanning overlay
   * 
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'), // Title displayed in the app bar
        backgroundColor: Colors.indigo, // Sets the app bar background color
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller, // Assigns the scanner controller
            onDetect: _foundBarcode, // Sets the callback for barcode detection
          ),
          // Overlay to indicate the scanning area
          Positioned(
            top: 100, // Position from the top of the screen
            left: 50, // Position from the left of the screen
            right: 50, // Position from the right of the screen
            child: Container(
              height: 250, // Height of the overlay box
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.indigo, width: 2), // Border styling
                borderRadius: BorderRadius.circular(
                    12), // Rounded corners for the overlay
              ),
            ),
          ),
        ],
      ),
    );
  }
}
