from flask import Flask, request, jsonify, send_file, render_template
from yt_dlp import YoutubeDL
from yt_dlp.utils import DownloadError
import os
import traceback

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
        # Docker内でDenoのパスを明示
        "js_runtimes": "deno:/usr/local/bin/deno",
        # YouTubeのJSチャレンジを回避する回避策
        "extractor_args": {"youtube": {"player_client": "default,-tv"}},
    }
    try:
        with YoutubeDL(opts) as ydl:
            info = ydl.extract_info(url, download=True)
            fp = (info.get("requested_downloads") or [{}])[0].get("filepath")
            if not fp or not os.path.exists(fp):
                return jsonify({"error": "ファイルが見つかりません"}), 500
            return send_file(fp, as_attachment=True, download_name="video.mp4")
    except DownloadError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": str(e), "trace": traceback.format_exc()}), 500

if __name__ == "__main__":
    app.run(port=10000)   
