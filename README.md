# 🛡️ Mobile QR Code Scanner with Malicious URL Detection

## 📋 Overview

This project combines mobile technology with machine learning to create a QR code scanner application that can detect potentially malicious URLs. When a user scans a QR code containing a URL, the app not only decodes the QR code but also analyzes the URL to determine if it might be a security threat.

<p align="center">
  <img src="screenshots/concept.png" alt="Project Concept Overview" width="300">
  <br>
  <em>General Concept of the Project</em>
</p>

## 🚀 Features

- **QR Code Scanning**: Quickly scan any QR code using your device's camera
- **Real-time URL Analysis**: Immediate classification of URLs as safe or potentially malicious
- **ML-powered Detection**: Utilizes a trained machine learning model to identify phishing and malicious URLs
- **Lightweight Implementation**: Model is optimized for mobile performance using TFLite
- **User-friendly Interface**: Clean, intuitive design with clear security indicators

## 📱 App Screenshots

*Screenshots showing the QR scanning interface and security analysis results*
<p align="center">
  <img src="screenshots/mobile_app.png" alt="QR Scanning Screen" width="400">
  <br>
  <em>An Overview</em>
</p>

<p align="center">
  <img src="screenshots/test_result_1.png" alt="Safe URL Result" width="400">
  <br>
  <em>Secure URL Result</em>
</p>

<p align="center">
  <img src="screenshots/test_result_2.png" alt="Malicious URL Result" width="400">
  <br>
  <em>Harmful URL Detection</em>
</p>

## 🏗️ Project Structure

The project is divided into two main components:

### 1. Backend (ML Model Training)

Located in the \`backend/training\` directory, this component is responsible for:

- **Data Preparation**: Processing and cleaning URL datasets (\`prepare_dataset.py\`)
- **Model Training**: Training the machine learning model to detect malicious URLs (\`train_model.py\`)
- **Model Conversion**: Converting the trained model to TFLite format for mobile deployment (\`convert_to_tflite.py\`)
- **Model Testing**: Validating the model's performance (\`test.py\`)

The backend uses a dataset of approximately 15,000+ labeled URLs (both safe and malicious) to train a classifier that can identify potentially harmful links.

### 2. Mobile Application

Located in the \`mobile_app\` directory, this Flutter-based application provides:

- A user interface for scanning QR codes
- Integration with the device's camera
- URL extraction from QR codes
- Feature extraction from URLs for analysis
- Integration with the TFLite model for classification
- Visual indicators for safe/malicious URLs

## 🧪 Technical Details

### Machine Learning Model

- **Dataset**: Over 15,000 labeled URLs (safe=0, malicious=1)
- **Features**: Extracts characteristics from URLs such as length, special character counts, domain information, etc.
- **Model Type**: Neural network classifier optimized for mobile deployment
- **Format**: TensorFlow Lite (.tflite) for on-device inference

### Mobile Application

- **Framework**: Flutter for cross-platform deployment
- **QR Scanning**: Utilizes device camera and QR code libraries
- **On-device Inference**: Performs URL classification directly on the device without requiring internet connection
- **Permissions**: Camera access for QR scanning

## 🔧 How It Works

1. User opens the app and points their camera at a QR code
2. The app decodes the QR code and extracts the URL
3. The URL undergoes feature extraction to create input for the ML model
4. The TFLite model analyzes these features and classifies the URL
5. The app displays the result to the user, indicating whether the URL is safe or potentially malicious
6. The user can then decide whether to visit the link or not

## 📊 Performance

The model achieves high accuracy in distinguishing between safe and malicious URLs, with detailed performance metrics available in the graduation project report. The on-device classification happens in milliseconds, providing users with immediate security feedback.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Android Studio or Xcode for mobile deployment
- Python 3.x for backend/model training (only if you wish to retrain the model)
- TensorFlow 2.x for model training

### Installation

1. Clone this repository
2. Set up the Flutter environment:
   ```
   cd mobile_app
   flutter pub get
   ```
3. Run the app:
   ```
   flutter run
   ```

## 🔒 Security Considerations

This application is designed to provide an additional layer of security when interacting with QR codes in public or unknown environments. However, it should not be considered a replacement for comprehensive security practices:

- Always exercise caution when clicking on links, even those identified as "safe"
- Keep your device and applications updated
- Use additional security tools for critical activities

## 👨‍💻 Development Notes

This project was developed as a graduation project and demonstrates the integration of machine learning with mobile technology to address a common security concern.

## 📚 Resources

- The full graduation project report is available in the repository as a PDF file
- The model training code is extensively commented to explain the machine learning approach
- The Flutter application code includes documentation for key components

## 📄 License

This project is intended for educational and personal use. 