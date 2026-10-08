FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Denoをバイナリで直接インストール（スクリプトより確実）
RUN curl -fsSL https://github.com/denoland/deno/releases/latest/download/deno-x86_64-unknown-linux-gnu.zip -o /tmp/deno.zip \
    && apt-get update && apt-get install -y unzip \
    && unzip /tmp/deno.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/deno \
    && rm /tmp/deno.zip

RUN pip install --no-cache-dir "yt-dlp[default]" flask gunicorn

WORKDIR /app
COPY . .

EXPOSE 10000
CMD ["gunicorn", "-b", "0.0.0.0:10000", "-w", "1", "app:app"]   
