"""
File: convert_to_tflite.py

This script loads a Keras model from a specified path and converts it to the TensorFlow Lite format,
writing the converted model to an output path.
"""
#!/usr/bin/env python3
# convert_to_tflite.py

import tensorflow as tf
import os

# The Keras model to be converted to TensorFlow Lite
model_keras_path = "model_save/model.keras"
# The output path for the converted TFLite model
tflite_output_path = "model_save/model.tflite"

# Log a message indicating that we are loading the Keras model
print(f"[INFO] Loading model from {model_keras_path}")
# Load the existing Keras model from the specified file
model = tf.keras.models.load_model(model_keras_path)

# Initialize the TFLiteConverter using the loaded Keras model
converter = tf.lite.TFLiteConverter.from_keras_model(model)
# Perform the conversion process and get the TFLite model
tflite_model = converter.convert()

# Ensure that the directory for the TFLite file exists (create if needed)
os.makedirs(os.path.dirname(tflite_output_path), exist_ok=True)

# Write the converted TFLite model to the specified file in binary mode
with open(tflite_output_path, 'wb') as f:
    f.write(tflite_model)

# Log a message indicating that the TFLite model has been successfully created
print(f"[INFO] TFLite model created at {tflite_output_path}")