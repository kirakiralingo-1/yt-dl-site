from flask import Flask, request, jsonify, send_file, render_template
from yt_dlp import YoutubeDL
import os

app = Flask(__name__)
DOWNLOAD_DIR = "/tmp/downloads"
os.makedirs(DOWNLOAD_DIR, exist_ok=True)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/download", methods=["POST"])
def download():
    url = request.json["url"]
    opts = {
        "format": "bestvideo[height<=720]+bestaudio/best[height<=720]",
        "outtmpl": os.path.join(DOWNLOAD_DIR, "%(id)s.%(ext)s"),
        "quiet": True,
        "no_warnings": True,
    }
    with YoutubeDL(opts) as ydl:
        info = ydl.extract_info(url, download=True)
        fp = (info.get("requested_downloads") or [{}])[0].get("filepath")
        return send_file(fp, as_attachment=True, download_name="video.mp4")

if __name__ == "__main__":
    app.run(port=10000)   
