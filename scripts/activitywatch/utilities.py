from datetime import datetime, time, timedelta, timezone
import socket

import aw_client

def afk():
    bucket_id = f"aw-watcher-afk_{socket.gethostname()}"

    daystart = datetime.combine(datetime.now().date(), time()).astimezone(timezone.utc)
    dayend = daystart + timedelta(days=1)

    awc = aw_client.ActivityWatchClient("testclient")
    events = awc.get_events(bucket_id, start=daystart, end=dayend)
    #print(events[0].data["status"])
    return ("afk" == events[0].data["status"])

def chrome():
    bucket_id = "aw-watcher-web-chrome"
    daystart = datetime.combine(datetime.now().date(), time()).astimezone(timezone.utc)
    dayend = daystart + timedelta(days=1)

    awc = aw_client.ActivityWatchClient("testclient")
    events = awc.get_events(bucket_id, start=daystart, end=dayend)
    return (events[0])

