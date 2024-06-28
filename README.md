# remwork
I was able to get shortcut working but not cron job.
I figured out the cron job was having permission issues with the rem database.
I had to add the /usr/bin/cron to full disk access in system settings.
In order to do that I had to add /usr to the finder favorites because the system settings would otherwise not allow my to browse to the folder and add it to the whitelist.
Now that the cron is working I don't think I will need to use the shortcute for the recurring process.
