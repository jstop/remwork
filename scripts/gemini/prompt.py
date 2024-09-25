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

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='geninie flash prompt')
    parser.add_argument('-f', '--filepath', type=str, required=True, help='The path to the file to process')
    parser.add_argument('-m', '--model', type=str, default="models/gemini-1.5-flash", help='The model to use')
    parser.add_argument('-p', '--prompt', type=str, default="summary", help='The prompt to use')

    args = parser.parse_args()
    main(args.filepath, args.model, args.prompt)
