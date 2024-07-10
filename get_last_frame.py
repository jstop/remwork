import os
import sqlite3
from datetime import datetime, timedelta
import subprocess

# Load environment variables from the .env file
from dotenv import load_dotenv

load_dotenv('/Users/jstein/workspace/ai/remwork/.env')

# Retrieve environment variables
WORKING_DIR = os.getenv('WORKING_DIR')
LOG_DIR = os.getenv('LOG_DIR')
VOICE_TOGGLE = os.getenv('VOICE_TOGGLE')
DEBUG_VOICE_TOGGLE = os.getenv('DEBUG_VOICE_TOGGLE')
DB_FILE = os.getenv('DB_FILE')
ADVICE_VOICE_TOGGLE = os.getenv('ADVICE_VOICE_TOGGLE')

# Read the necessary files
with open(os.path.join(WORKING_DIR, '.settings', 'run_switch.txt'), 'r') as f:
    RUN_SWITCH = f.read().strip()

with open(VOICE_TOGGLE, 'r') as f:
    VOICE_STATE = f.read().strip()

with open(ADVICE_VOICE_TOGGLE, 'r') as f:
    ADVICE_VOICE_STATE = f.read().strip()

with open(DEBUG_VOICE_TOGGLE, 'r') as f:
    VOICE_DEBUG = f.read().strip()

if RUN_SWITCH == "OFF":
    if VOICE_DEBUG == "ON":
        subprocess.run(["say", "-r", "200", "Run switch is off. Exiting."])
    exit(0)
else:
    with open(os.path.join(WORKING_DIR, '.settings', 'run_switch.txt'), 'w') as f:
        f.write("OFF")

FRAME_ID_FILE = os.path.join(WORKING_DIR, 'tmp', 'last_frame_id.txt')
LOG_FILE = os.path.join(WORKING_DIR, 'logs', datetime.now().strftime("%Y.%m.%d.%H.%M.%S") + '.log')

# Read the last frameId from the file
if os.path.isfile(FRAME_ID_FILE):
    with open(FRAME_ID_FILE, 'r') as f:
        LAST_FRAME_ID = f.read().strip()
    if VOICE_DEBUG == "VERBOSE":
        subprocess.run(["say", "-r", "200", f"Last frame ID: {LAST_FRAME_ID}"])
    else:
        with open(LOG_FILE, 'a') as log:
            log.write(f"Last frame ID: {LAST_FRAME_ID}\n")
else:
    subprocess.run(["say", "-r", "200", "Frame ID file not found."])
    LAST_FRAME_ID = "10"

# Query the database for the latest frameId
conn = sqlite3.connect(DB_FILE)
cursor = conn.cursor()

cursor.execute("SELECT frameId FROM allText ORDER BY frameId DESC LIMIT 1;")
LATEST_FRAME_ID = cursor.fetchone()[0]

cursor.execute(f"SELECT timestamp FROM frames WHERE id = {LATEST_FRAME_ID};")
LATEST_FRAME_TIMESTAMP = cursor.fetchone()[0]

if VOICE_DEBUG == "VERBOSE":
    subprocess.run(["say", "-r", "200", f"Latest Frame ID: {LATEST_FRAME_ID}"])

# Compare the frame IDs
if LAST_FRAME_ID == str(LATEST_FRAME_ID):
    if VOICE_DEBUG == "ON":
        subprocess.run(["say", "-r", "200", "Frame ID has not changed. Exiting."])
    else:
        with open(LOG_FILE, 'a') as log:
            log.write("Frame ID has not changed. Exiting.\n")
    with open(os.path.join(WORKING_DIR, 'tmp', 'is_running.txt'), 'w') as f:
        f.write("FALSE")
    conn.close()
    exit(0)
else:
    if VOICE_DEBUG == "VERBOSE":
        subprocess.run(["say", "-r", "200", f"Frame ID has changed. New frame ID: {LATEST_FRAME_ID}"])
    with open(FRAME_ID_FILE, 'w') as f:
        f.write(str(LATEST_FRAME_ID))

# Write frame to file
FILENAME = os.path.join(WORKING_DIR, 'tmp', 'last_frame.txt')
query = """
.mode csv
.headers on
.output {}
SELECT text FROM allText
ORDER BY frameId DESC
LIMIT 1;
.output stdout
""".format(FILENAME)

subprocess.run(['sqlite3', DB_FILE], input=query.encode(), check=True)

if VOICE_DEBUG == "VERBOSE":
    subprocess.run(["say", "-r", "200", f"Frame text written to {FILENAME}"])
else:
    with open(LOG_FILE, 'a') as log:
        log.write(f"Frame text written to {FILENAME}\n")

# Summarize frame
activate_script = os.path.join(WORKING_DIR, 'bin', 'activate')
summarize_script = os.path.join(WORKING_DIR, 'gemini_flash_summarize.py')
summary_output = os.path.join(WORKING_DIR, 'summaries', f"{LATEST_FRAME_TIMESTAMP}.txt")

subprocess.run(f"source {activate_script} && python3 {summarize_script} < {FILENAME} > {summary_output} 2>> {LOG_FILE}", shell=True)

cp_now = os.path.join(WORKING_DIR, 'summaries', 'now.txt')
subprocess.run(["cp", summary_output, cp_now])

if VOICE_DEBUG == "ON":
    subprocess.run(["say", "-r", "200", "New Summary available"])

if VOICE_STATE == "ON":
    time_str = (datetime.strptime(LATEST_FRAME_TIMESTAMP, '%Y-%m-%d %H:%M:%S') - timedelta(hours=4)).strftime('%A at %I:%M %p')
    subprocess.run(["say", "-r", "140", f"At {time_str}"])
    subprocess.run(["say", "-r", "180", "-f", cp_now])
    if ADVICE_VOICE_STATE == "ON":
        subprocess.run(["say", "-r", "140", f"At {time_str}"])
        advice_now = os.path.join(WORKING_DIR, 'advice', 'now.txt')
        subprocess.run(["say", "-r", "180", "-f", advice_now])

with open(os.path.join(WORKING_DIR, '.settings', 'run_switch.txt'), 'w') as f:
    f.write("ON")

conn.close()
