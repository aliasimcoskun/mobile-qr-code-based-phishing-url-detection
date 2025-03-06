"""
File : prepare_dataset.py

This script reads two CSV files containing URLs, one with safe URLs and one with phishing URLs.
"""
import pandas as pd

# Read data
df_zararli = pd.read_csv('data/new_zararli_15k.csv', on_bad_lines='skip')  # skip malformed lines
df_safe = pd.read_csv("data/safe.csv")

# Select at random
df_safe_sample = df_safe.sample(n=15000, random_state=42)

# Merge
df_merged = pd.concat([df_zararli, df_safe_sample], ignore_index=True)

# Save as new csv
df_merged.to_csv("data/combined_dataset.csv", index=False)