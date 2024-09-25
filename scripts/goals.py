import sys
import google.generativeai as genai
import os
import subprocess
from dotenv import load_dotenv
import argparse

def main(filepath, model, prompt):
    load_dotenv('/Users/jstein/workspace/ai/remwork/.env')
    GOOGLE_API_KEY=os.getenv('GOOGLE_API_KEY')
    WORKING_DIR=os.getenv('WORKING_DIR')
    genai.configure(api_key=os.getenv('GOOGLE_API_KEY'))
    gemini = genai.GenerativeModel('models/gemini-1.5-flash')
    with open(filepath, 'r') as f:
        content = f.read()
    with open(f"{WORKING_DIR}/prompts/{prompt}.txt", 'r') as f:
        prompt = f.read()

    context="Summaries of screen captures were created throughout the day yesterday and were compiled into a single file."

    formatted_prompt = f"{context} -------------------- Summary: ------------- {content} ---------------------- Please answer the question: {prompt}"
    response = gemini.generate_content(formatted_prompt)
    print(response.text)
response = gemini.generate_content(formatted_prompt)
