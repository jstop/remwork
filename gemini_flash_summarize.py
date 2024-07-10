#!pip install -U -q google-generativeai
import sys
import google.generativeai as genai
import os
import subprocess
from dotenv import load_dotenv

load_dotenv('/Users/jstein/workspace/ai/remwork/.env')
GOOGLE_API_KEY=os.getenv('GOOGLE_API_KEY')
genai.configure(api_key=os.getenv('GOOGLE_API_KEY'))

model = genai.GenerativeModel('models/gemini-1.5-flash')
input_content = sys.stdin.read()

context="For your context, the following refrence material was extracted from a screen capture tool that may capture an entire screen or just an application window. The text may seem disjointed as the translation from screen shot to text is not aware of seperate windows of conext."
question="Can you breifly summarize what the screenshot text suggests the user(Josh) was doing in two brief sentences?\n\n"
followup=""
formatted_prompt = f"{context} -------------------- Reference material: ------------- {input_content} ------------------ Please answer the query using the provided information: {question}---------------------------------------------------------------------------{followup}"
response = model.generate_content(formatted_prompt)
print(response.text)
