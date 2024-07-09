## Settings
I'm using shortcuts on mac to execute the toggle scripts in settings/scripts/
With voice commands on mac I can link a shortcut to a voice command. As I'm developing I can say "Talk to me" the script is executed and the voice will say "speech enabled"
 - Mac Voice commands are not working so well though I need to work on using whisper
I can also say "Quiet Please" and when the script is executed the voice will say "I'll be quiet now"
I have a similar commands configured for debugging using comands "debugging on/off"


## Functionality
So far this project will run my script every 2 minutes. During the process it checks for the newest frame in the rem database pulls the text extracted from it and summarizes my activity. It saves the summary to a file in my workspace and then reads the summary out loud if I have the voice enabled.
Next I want to add followup prompts to the summary. I'll start with and advice prompt.


## ROAD MAP

Add memory device acknowledge common advice so that it is not reapeated in future advice.

## Crontab
 */1 * * * * /Users/jstein/workspace/ai/remwork/summarize_last_frame.sh
 0 * * * * /Users/jstein/workspace/ai/remwork/scripts/daily.sh /Users/jstein/workspace/ai/remwork/summaries 0
 0 * * * * /Users/jstein/workspace/ai/remwork/scripts/daily.sh /Users/jstein/workspace/ai/remwork/summaries 1

### Notes
At first I was able to get shortcut working but not cron job.
I figured out the cron job was having permission issues with the rem database.
I had to add the /usr/bin/cron to full disk access in system settings.
In order to do that I had to add /usr to the finder favorites because the system settings would otherwise not allow my to browse to the folder and add it to the whitelist.
Now that the cron is working I don't think I will need to use the shortcut for the recurring process.
I am now able to call the bash script directly from cron so I don't need the shortcut.
