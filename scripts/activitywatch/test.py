from datetime import datetime, time, timedelta
from pytz import timezone

import socket

import aw_client


if __name__ == "__main__":
    bucket_id = f"aw-watcher-afk_{socket.gethostname()}"
    # Time now in UTC
    time_range_end = datetime.now(timezone('UTC'))
    print(f"Time now: {time_range_end}")
    # Time m minutes ago in UTC
    m = 10
    h = 0
    time_range_start = datetime.now(timezone('UTC')) - timedelta(minutes=m, hours=h)
    print(f"Time {h} hours and {m} minutes ago: {time_range_start}")

    awc = aw_client.ActivityWatchClient("testclient")
    events = awc.get_events(bucket_id, start=time_range_start, end=time_range_end)
    #example data
    # {'id': 36936, 'timestamp': datetime.datetime(2024, 9, 23, 17, 57, 2, 222000, tzinfo=datetime.timezone.utc), 'duration': datetime.timedelta(seconds=49, microseconds=163000), 'data': {'status': 'not-afk'}}

    #current even status
    print(events[0].data["status"])
    #events = [e for e in events if e.data["status"] == "afk"]
    #print(f"Most recent time they are afk: {max(e.timestamp for e in events)}")
    ##print total time they are afk
    #total_duration = sum((e.duration for e in events), timedelta())
    #print(f"Total time they are afk: {total_duration}")


    ##print the timestamp in localtimezone for each event in events
    #for e in events:
    #    print(e.timestamp, e.duration, e.data["status"])
    #total_duration = sum((e.duration for e in events), timedelta())
    #print(f"Total time spent away from computer today: {total_duration}")
