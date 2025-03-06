"""
File: train_model.py

This script trains a simple neural network model to classify URLs as phishing or safe based on several features extracted from the URLs.
"""

#!/usr/bin/env python3
# train_model.py

import pandas as pd
import numpy as np
import tensorflow as tf
from urllib.parse import urlparse
import ipaddress
from sklearn.model_selection import train_test_split
import os
from sklearn.metrics import precision_score, recall_score, f1_score

"""
featureExtraction method

This method extracts several features from the given URL.

Parameters:
- url: The URL to analyze

Returns:
- A list of numerical features for the model
"""
def featureExtraction(url):
    """
    1) domain_length
    2) having ip address
    3) having @ symbol
    4) url length
    5) url depth
    6) redirection
    7) https in domain
    8) tinyurl (tinyurl/bit.ly in domain)
    9) prefix_suffix ( '-' in domain)
    """
    try:
        parsed = urlparse(url)
        # print(f"Parsed: {parsed}")

        scheme = parsed.scheme
        domain = parsed.netloc
        path = parsed.path
        # print(f"Domain: {domain}")
        # print(f"Path: {path}")

        # 1. domain_length
        domain_length = len(domain)
        # print(f"domain_length: {domain_length}")

        # 2. having ip address
        try:
            ipaddress.ip_address(domain)
            have_ip = 1
        except:
            have_ip = 0
        # print(f"have_ip: {have_ip}")

        # 3. having @ symbol
        have_at = 1 if "@" in url else 0
        # print(f"have_at: {have_at}")

        # 4. url length
        url_length = len(url)
        # print(f"url_length: {url_length}")
                             
        # 5. url depth
        # count of path segments
        url_depth = len([x for x in path.split("/") if x != ""])
        # print(f"url_depth: {url_depth}")

        # 6. redirection
        # look if '//' appears in path
        redirection = 1 if '//' in path else 0
        # print(f"redirection: {redirection}")

        # 7. https in domain
        https_domain = 1 if 'https' in scheme else 0
        # print(f"https_domain: {https_domain}")

        # 8. tinyurl
        tiny_url = 1 if ('tinyurl' in domain or 'bit.ly' in domain) else 0
        # print(f"tiny_url: {tiny_url}")

        # 9. prefix or suffix in domain
        prefix_suffix = 1 if '-' in domain else 0
        # print(f"prefix_suffix: {prefix_suffix}")

        return [
            domain_length,
            have_ip,
            have_at,
            url_length,
            url_depth,
            redirection,
            https_domain,
            tiny_url,
            prefix_suffix
        ]
    except:
        # in case of parse error
        print(f"[ERROR] Failed to parse {url}")
        return [0]*9

"""
train_and_save_model method

This method trains a classification model using a dataset of URLs and saves the trained model.

Parameters:
- csv_path: Path to the CSV dataset
- model_path: Output path for the trained model file

Returns:
- The training history object after model.fit()
"""
def train_and_save_model(csv_path='data/dataset.csv', model_path='model.keras'):
    # 1) Read dataset
    # The dataset is read from a CSV file. Rows with parsing problems are skipped.
    df = pd.read_csv(csv_path, on_bad_lines='skip')
    
    # 2) Build X,y using all data
    # Here we prepare the feature matrix (X) and labels (y).
    X = []
    y = df['label'].values

    # Each URL from the DataFrame is passed to the featureExtraction function, and the resulting vector is appended to X.
    for url in df['url']:
        feats = featureExtraction(url)
        X.append(feats)

    # Convert the list of feature vectors into a NumPy array of floats.
    X = np.array(X, dtype=np.float32)

    # 2.1 Split data into training and testing sets
    # We use an 80/20 train-test split strategy.
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # 3) Build and train model with all data
    # We define a sequential Keras model with several Dense layers, BatchNormalization, and Dropout layers.
    model = tf.keras.models.Sequential([
        tf.keras.layers.Input(shape=(9,)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dense(32, activation='relu'),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dense(16, activation='relu'),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dense(8, activation='relu'),
        tf.keras.layers.Dense(1, activation='sigmoid')
    ])

    # We set up an exponential decay schedule for the learning rate and use the Adam optimizer.
    initial_learning_rate = 0.001
    lr_schedule = tf.keras.optimizers.schedules.ExponentialDecay(
        initial_learning_rate, decay_steps=1000, decay_rate=0.9
    )
    optimizer = tf.keras.optimizers.Adam(learning_rate=lr_schedule)

    # Compile the model with binary crossentropy loss and accuracy as the metric.
    model.compile(
        optimizer=optimizer,
        loss='binary_crossentropy',
        metrics=['accuracy']
    )

    # 4) Train with all data
    # The model is trained for 50 epochs on the entire data using a batch size of 64.
    history = model.fit(
        X, y,
        epochs=50,
        batch_size=64,
        verbose=1
    )

    # 5) Evaluate model
    # We evaluate the model on the test set to measure performance metrics.
    loss, accuracy = model.evaluate(X_test, y_test, verbose=0)
    y_pred = (model.predict(X_test) > 0.5).astype(int)
    
    precision = precision_score(y_test, y_pred)
    recall = recall_score(y_test, y_pred)
    f1 = f1_score(y_test, y_pred)
    
    print(f"Accuracy: {accuracy * 100:.2f}%")
    print(f"Precision: {precision * 100:.2f}%")
    print(f"Recall: {recall * 100:.2f}%")
    print(f"F1 Score: {f1 * 100:.2f}%")

    # 6) Save final model
    # The trained model is saved to the specified location for future use.
    model.save(model_path)
    print(f"[INFO] Model saved to {model_path}")

    return history

if __name__ == "__main__":
    # Example usage with better error handling
    # Here the function is called with default paths for both CSV data and model saving.
    history = train_and_save_model(
        csv_path='data/dataset.csv', 
        model_path='model_save/model.keras'
    )
    
    if history is None:
        print("[ERROR] Training failed")
    else:
        print("[SUCCESS] Model training completed")