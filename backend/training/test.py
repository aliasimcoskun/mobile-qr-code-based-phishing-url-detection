"""
File: test.py

This script loads a trained Keras model and evaluates it on various test URLs,
predicting whether each URL is phishing or safe.
"""
#!/usr/bin/env python3
# test.py

import tensorflow as tf
import numpy as np
from train_model import featureExtraction

# Load the saved model
model = tf.keras.models.load_model('model_save/model.keras')

# Test URLs
test_urls = [
"https://secure.online-banking.creditunion-westcoast.com/account/dashboard/login",
"https://my.cloud-storage.enterprise-solutions.net/workspace/documents/shared",
"https://customer-portal.healthcare-network.org/appointments/schedule",
"https://learn.professional-certification.edu/courses/cybersecurity/module-5",
"https://shop.electronics-marketplace.retail-chain.com/products/category/phones",
"https://careers.global-technology.corporate-group.net/apply/engineering",
"https://support.software-solutions.business-tools.com/knowledge/articles",
"https://connect.research-institute.academic-center.edu/publications/2024",
"https://services.government-portal.administrative.gov/citizens/forms",
"https://webmail.enterprise-communications.network/inbox/messages",

 "https://banking-secure-login.account0x7f3d2.xyz/verify/details",
 "https://secur1ty-update.cloud-storage.onl1ne-verify.net/confirm",
 "https://online-banking.secure-server.accountverify.co/login",
 "https://payment-verify.banking-services.secureserver.tk/update",
 "https://account-security.banking-verify.authorize.pw/check",
 "https://myaccount.security-update.login-verify.cf/confirm",
 "https://secure.customer-verification.account-update.ml/verify",
 "https://banking.security-check.account-confirm.ga/validate",
 "https://verification-required.account-secure.banking-update.gq/auth",
 "https://secure-login.customer-support.account-verify.ws/check"
]

# Run predictions
for url in test_urls:
    features = np.array([featureExtraction(url)])
    prediction = model.predict(features)
    label = 1 if prediction[0][0] >= 0.5 else 0
    print(f"{url} -> {'Phishing' if label == 1 else 'Safe'} | Prob: {prediction[0][0]:.4f}")