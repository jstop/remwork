#!pip install -U -q google-generativeai
import google.generativeai as genai
from IPython.display import Markdown
import PIL.Image
import time
from dotenv import load_dotenv
import os

load_dotenv('/Users/jstein/workspace/ai/remwork/.env')
GOOGLE_API_KEY=os.getenv('GOOGLE_API_KEY')
genai.configure(api_key=os.getenv('GOOGLE_API_KEY'))
model = genai.GenerativeModel(model_name="gemini-1.5-flash")

video_file_name = "screen_capture.mp4"
print(f"Uploading file...")
video_file = genai.upload_file(path=video_file_name)
print(f"Completed upload: {video_file.uri}")

# Check whether the file is ready to be used.
while video_file.state.name == "PROCESSING":
    print('.', end='')
    time.sleep(10)
    video_file = genai.get_file(video_file.name)

if video_file.state.name == "FAILED":
  raise ValueError(video_file.state.name)

#prompt = "Write an advertising jingle showing how the product in the first image could solve the problems shown in the second two images."
prompt = "Describe the video."

print("Making LLM inference request...")
response = model.generate_content([video_file, prompt],
                                  request_options={"timeout": 600})

print(response.text)
