FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deno.land/install.sh | DENO_INSTALL=/usr/local sh

RUN pip install --no-cache-dir "yt-dlp[default]" flask gunicorn

WORKDIR /app
COPY . .

EXPOSE 10000
CMD ["gunicorn", "-b", "0.0.0.0:10000", "-w", "1", "app:app"]   
