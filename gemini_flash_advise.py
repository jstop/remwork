import sys
import google.generativeai as genai
import os
import subprocess
from dotenv import load_dotenv

load_dotenv('/Users/jstein/workspace/ai/remwork/.env')
GOOGLE_API_KEY=os.getenv('GOOGLE_API_KEY')
genai.configure(api_key=os.getenv('GOOGLE_API_KEY'))

model = genai.GenerativeModel('models/gemini-1.5-flash')
summary = sys.stdin.read()

context="A summary of what the user(Josh) was possibly engaged in was taken from the screen captures."

question="Can you give Josh 3 pieces of advice to help him with advance the goal of what he is doing?\n\n"
followup=""
formatted_prompt = f"{context} -------------------- Reference material: ------------- {summary} ------------------ Please answer the query using the provided information: {question}---------------------------------------------------------------------------{followup}"
response = model.generate_content(formatted_prompt)
print(response.text)
