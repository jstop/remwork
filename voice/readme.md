# Setup hotkey to listen and transcribe audio
#pip install openai-whisper pyaudio keyboard

import whisper
import pyaudio
import keyboard
import time

def transcribe_audio():
   # Initialize Whisper model
   model = whisper.load_model("base")

   # Initialize PyAudio
   audio = pyaudio.PyAudio()
   stream = audio.open(format=pyaudio.paInt16, channels=1, rate=44100, input=True)

   print("Recording...")
   frames = []
   while True:
       data = stream.read(1024)
       frames.append(data)
       if keyboard.is_pressed('esc'):  # Press 'Esc' to stop recording
           break

   print("Transcribing...")
   stream.stop_stream()
   stream.close()
   audio.terminate()

   # Transcribe the audio
   result = model.transcribe(frames)

   # Simulate keyboard input
   keyboard.write(result["text"])

# Set up the trigger
keyboard.add_hotkey('ctrl+shift+v', transcribe_audio)  # Activate with Ctrl+Shift+V

# Keep the script running
while True:
   time.sleep(1)
