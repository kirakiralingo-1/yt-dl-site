FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg curl unzip git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Deno
RUN curl -fsSL https://github.com/denoland/deno/releases/latest/download/deno-x86_64-unknown-linux-gnu.zip -o /tmp/deno.zip \
    && unzip /tmp/deno.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/deno \
    && rm /tmp/deno.zip

# bgutil POTサーバー（branch 2.0.2 + npm ci）
RUN git clone --single-branch --branch 2.0.2 \
    https://github.com/Brainicism/bgutil-ytdlp-pot-provider.git /opt/bgutil \
    && cd /opt/bgutil/server \
    && npm ci \
    && npx tsc

# Python（yt-dlp + 公式プラグイン）
RUN pip install --no-cache-dir \
    "yt-dlp[default]" \
    flask \
    gunicorn \
    bgutil-ytdlp-pot-provider

WORKDIR /app
COPY . .

EXPOSE 10000

# bgutilサーバー起動 → 起動確認 → gunicorn起動
CMD ["sh", "-c", "\
    node /opt/bgutil/server/build/main.js --port 4416 & \
    for i in $(seq 1 10); do \
        curl -s http://127.0.0.1:4416/ping > /dev/null 2>&1 && break; \
        sleep 1; \
    done; \
    echo 'bgutil server ready'; \
    gunicorn -b 0.0.0.0:10000 -w 1 app:app"]   
