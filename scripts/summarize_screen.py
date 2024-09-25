import os
import sqlite3
import subprocess
import json
from datetime import datetime, timedelta
from activitywatch import utilities as aw

# Load environment variables
from dotenv import load_dotenv
load_dotenv('/Users/jstein/workspace/ai/remwork/.env')

WORKING_DIR = os.getenv('WORKING_DIR')
VOICE_TOGGLE = os.getenv('VOICE_TOGGLE')
ADVICE_VOICE_TOGGLE = os.getenv('ADVICE_VOICE_TOGGLE')
DEBUG_VOICE_TOGGLE = os.getenv('DEBUG_VOICE_TOGGLE')
PDS_PATH = os.getenv('PDS_PATH')
DB_FILE = os.getenv('DB_FILE')

def read_file(file_path):
    with open(file_path, 'r') as file:
        return file.read().strip()

def write_file(file_path, content):
    with open(file_path, 'w') as file:
        file.write(content)

def say(text, rate=200):
    subprocess.run(['say', '-r', str(rate), text])

def log(message, log_file):
    with open(log_file, 'a') as file:
        file.write(f"{message}\n")

def main():
    run_switch = read_file(f"{WORKING_DIR}/.settings/run_switch.txt")
    voice_state = read_file(VOICE_TOGGLE)
    advice_voice_state = read_file(ADVICE_VOICE_TOGGLE)
    voice_debug = read_file(DEBUG_VOICE_TOGGLE)
    afk = aw.afk()
    if afk:
        if voice_debug == "ON":
            say("AFK. Exiting.", 200)
        return 0
    else:
        if voice_debug == "ON":
            say("Not AFK. Continuing.", 200)

    if run_switch == "OFF":
        if voice_debug == "ON":
            say("Run switch is off. Exiting.", 200)
        return

    # Turn the run switch off at the start of a new execution
    write_file(f"{WORKING_DIR}/.settings/run_switch.txt", "OFF")

    frame_id_file = f"{WORKING_DIR}/tmp/last_frame_id.txt"
    log_file = f"{PDS_PATH}/logs/{datetime.now().strftime('%Y.%m.%d.%H')}.log"

    if os.path.exists(frame_id_file):
        last_frame_id = read_file(frame_id_file)
        if voice_debug == "VERBOSE":
            say(f"Last frame ID: {last_frame_id}", 200)
        else:
            log(f"Last frame ID: {last_frame_id}", log_file)
    else:
        say("Frame ID file not found.", 200)
        last_frame_id = 10

    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()

    cursor.execute("SELECT frameId FROM allText ORDER BY frameId DESC LIMIT 1")
    latest_frame_id = cursor.fetchone()[0]

    cursor.execute("SELECT timestamp FROM frames WHERE id = ?", (latest_frame_id,))
    latest_frame_timestamp = cursor.fetchone()[0]

    if voice_debug == "VERBOSE":
        say(f"Latest Frame ID: {latest_frame_id}", 200)

    if last_frame_id == latest_frame_id:
        if voice_debug == "ON":
            say("Frame ID has not changed. Exiting.", 200)
        else:
            log("Frame ID has not changed. Exiting.", log_file)
        write_file(f"{WORKING_DIR}/tmp/is_running.txt", "FALSE")
        return

    if voice_debug == "VERBOSE":
        say(f"Frame ID has changed. New frame ID: {latest_frame_id}", 200)
    write_file(frame_id_file, str(latest_frame_id))

    filename = f"{WORKING_DIR}/tmp/last_frame.txt"
    cursor.execute("SELECT text FROM allText ORDER BY frameId DESC LIMIT 1")
    frame_text = cursor.fetchone()[0]
    conn.close()

    write_file(filename, frame_text)

    if voice_debug == "VERBOSE":
        say(f"Frame text written to {filename}", 200)
    else:
        log(f"Frame text written to {filename}", log_file)

    # Summarize frame
    summary_file = f"{PDS_PATH}/summaries/{latest_frame_timestamp}.txt"
    summary_comparison_file = f"{PDS_PATH}/summaries/comparison-{latest_frame_timestamp}.txt"
    goal_file = f"{PDS_PATH}/goals/{latest_frame_timestamp}.txt"
    subprocess.run([f"{WORKING_DIR}/bin/python3", f"{WORKING_DIR}/scripts/gemini/flash_summarize.py"],
                   input=frame_text.encode(),
                   stdout=open(summary_file, 'w'),
                   stderr=open(log_file, 'a'))

    subprocess.run([f"{WORKING_DIR}/bin/python3", f"{WORKING_DIR}/scripts/gemini/flash_compare.py"],
                   input=("new summary:\n" + read_file(summary_file) +"\n\n last summary: \n" + read_file(f"{PDS_PATH}/summaries/now.txt")).encode(),
                   stdout=open(summary_comparison_file, 'w'),
                   stderr=open(log_file, 'a'))

    subprocess.run([f"{WORKING_DIR}/bin/python3", f"{WORKING_DIR}/scripts/gemini/flash_summarize.py"],
                   input=frame_text.encode(),
                   stdout=open(goal_file, 'w'),
                   stderr=open(log_file, 'a'))

    os.system(f"cp {summary_file} {PDS_PATH}/summaries/now.txt")
    os.system(f"cp {summary_comparison_file} {PDS_PATH}/summaries/comparison-now.txt")
    os.system(f"cp {goal_file} {PDS_PATH}/goals/now.txt")

    if voice_debug == "ON":
        say("New Summary available", 200)

    if voice_state == "ON":
        # Parse the ISO format timestamp
        timestamp = datetime.fromisoformat(latest_frame_timestamp) - timedelta(hours=4)
        say(f"At {timestamp.strftime('%A at %I:%M %p')}", 140)

        #parse json from summary_comparison_file
        summary_comparison = json.load(open(summary_comparison_file, 'r'))
        if summary_comparison['answer'] == "no":
            say(summary_comparison['difference'])
        else:
            with open(f"{PDS_PATH}/summaries/comparison-now.txt", 'r') as f:
                say(f.read(), 180)
            with open(f"{PDS_PATH}/summaries/now.txt", 'r') as f:
                say(f.read(), 180)
        if advice_voice_state == "ON":
            say(f"At {timestamp.strftime('%A at %I:%M %p')}", 140)
            with open(f"{PDS_PATH}/advice/now.txt", 'r') as f:
                say(f.read(), 180)

    # Allow new execution when this execution completes
    write_file(f"{WORKING_DIR}/.settings/run_switch.txt", "ON")


if __name__ == "__main__":
    main()
