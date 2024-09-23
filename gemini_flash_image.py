#!pip install -U -q google-generativeai
import google.generativeai as genai
from IPython.display import Markdown
import PIL.Image
from dotenv import load_dotenv
import os
load_dotenv('/Users/jstein/workspace/ai/remwork/.env')
GOOGLE_API_KEY=os.getenv('GOOGLE_API_KEY')
genai.configure(api_key=os.getenv('GOOGLE_API_KEY'))

model = genai.GenerativeModel(model_name="gemini-1.5-flash")
sample_file = PIL.Image.open('screenshot_test.png')
prompt = "Describe the picture."

response = model.generate_content([prompt, sample_file])

print(response.text)
