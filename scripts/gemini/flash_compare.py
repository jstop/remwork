#!pip install -U -q google-generativeai
import sys
import google.generativeai as genai
from google.generativeai.types import HarmCategory, HarmBlockThreshold
import os
import subprocess
from dotenv import load_dotenv

load_dotenv('/Users/jstein/workspace/ai/remwork/.env')
GOOGLE_API_KEY=os.getenv('GOOGLE_API_KEY')
genai.configure(api_key=os.getenv('GOOGLE_API_KEY'))

model = genai.GenerativeModel('models/gemini-1.5-flash')
input_content = sys.stdin.read()

context="For your context, I am providing you with two summaries that may have been captured within 2 minutes of each other."
question="Does the new summary suggest the user is still engaged in the same thing as they were in the previous summary?\n\n"
followup="Please format your answer in a json object with the following format: {\"answer\": \"yes\" or \"no\" \"difference\": \"explanation\"} and do not include formatting characters like ```json ...```."
formatted_prompt = f"{context} -------------------- Reference material: ------------- {input_content} ------------------ Please answer the query using the provided information: {question}---------------------------------------------------------------------------{followup}"
response = model.generate_content(
    formatted_prompt,
    safety_settings={
        HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_NONE,
        HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_NONE,
        HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_NONE,
        HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_NONE
    }
)
#check the `candidate.safety_ratings` to determine if the response was blocked.
#print(response)
print(response.text)
