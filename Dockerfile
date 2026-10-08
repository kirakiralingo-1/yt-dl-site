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

# bgutil POTサーバー（latestブランチ、npm installに変更）
RUN git clone --depth 1 https://github.com/Brainicism/bgutil-ytdlp-pot-provider.git /opt/bgutil \
    && cd /opt/bgutil/server \
    && npm install \
    && npx tsc

# Python
RUN pip install --no-cache-dir "yt-dlp[default]" flask gunicorn bgutil-ytdlp-pot-provider

WORKDIR /app
COPY . .

# ★ 重要: yt-dlpがPOTサーバーを見つけるための環境変数
ENV YTDLP_POT_PROVIDER_URL=http://127.0.0.1:4416

EXPOSE 10000

# bgutilを起動 → 3秒待つ → gunicorn起動
CMD ["sh", "-c", "node /opt/bgutil/server/build/main.js --port 4416 & sleep 3 && gunicorn -b 0.0.0.0:10000 -w 1 app:app"]   
