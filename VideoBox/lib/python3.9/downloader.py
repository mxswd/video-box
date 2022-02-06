import youtube_dl
from youtube_dl.extractor import youtube
import json
import traceback

def download(url, outputPath, callback):
    def yt_callback(obj):
        callback(json.dumps(obj))
    try:
        ytdl = youtube_dl.YoutubeDL({
            "nocheckcertificate": True,
            "progress_hooks": [yt_callback],
            "restrictfilenames": True,
            "nooverwrites": True,
            "format": "best[ext=mp4]",
            "outtmpl": outputPath
        })
        ytdl.download([url])
    except Exception:
        print("error:")
        print(traceback.format_exc())
        raise
