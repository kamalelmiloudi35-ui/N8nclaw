# VIRAL EMPIRE v8.0 - Final Fixed Edition (No Parse Errors)
# آخر تحديث: يناير 2026
# تم إصلاح مشكلة parse error في سطور الخطوط (إزالة التعليقات داخل multi-line RUN)
# كل التعليقات خارج الأوامر لتجنب أي مشاكل في Docker parser

FROM node:20-bookworm-slim

LABEL maintainer="Viral Empire Team (Enhanced by Grok)"
LABEL version="8.0"
LABEL description="n8n with Full FFmpeg, yt-dlp, aria2, Arabic Fonts - Optimized for Video Automation"

ARG DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# تثبيت الأدوات الأساسية
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    gnupg \
    bash \
    coreutils \
    procps \
    && rm -rf /var/lib/apt/lists/*

# تثبيت FFmpeg
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# تثبيت Python + pip
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    && rm -rf /var/lib/apt/lists/*

# تثبيت yt-dlp + aria2
RUN apt-get update && apt-get install -y --no-install-recommends \
    aria2 \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --break-system-packages --no-cache-dir yt-dlp

# تثبيت الأدوات المساعدة
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    sed \
    gawk \
    grep \
    zip \
    unzip \
    file \
    mediainfo \
    bc \
    git \
    openssh-client \
    atomicparsley \
    && rm -rf /var/lib/apt/lists/*

# تثبيت الخطوط العربية الكاملة (إصلاح كامل: لا تعليقات داخل الـ RUN)
RUN apt-get update && apt-get install -y --no-install-recommends \
    fontconfig \
    fonts-dejavu-core \
    fonts-liberation \
    fonts-noto-core \
    fonts-noto-extra \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    fonts-hosny-amiri \
    fonts-kacst \
    fonts-arabeyes \
    && fc-cache -f -v \
    && rm -rf /var/lib/apt/lists/*

# إنشاء المجلدات
RUN mkdir -p /tmp/videos && chmod 1777 /tmp/videos \
    && mkdir -p /data && chmod 777 /data \
    && mkdir -p /home/node/.n8n && chown -R node:node /home/node \
    && mkdir -p /downloads && chmod 777 /downloads

# تثبيت n8n
RUN npm install -g n8n@latest --omit=dev \
    && npm cache clean --force

# المنطقة الزمنية
ENV TZ=Asia/Riyadh
ENV GENERIC_TIMEZONE=Asia/Riyadh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# إعدادات n8n
ENV N8N_PORT=5678
ENV N8N_HOST=0.0.0.0
ENV N8N_PROTOCOL=https
ENV N8N_LOG_LEVEL=info
ENV NODE_FUNCTION_ALLOW_BUILTIN=*
ENV NODE_FUNCTION_ALLOW_EXTERNAL=*
ENV N8N_BLOCK_ENV_ACCESS_IN_NODE=false
ENV EXECUTIONS_PROCESS=main
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/data/database.sqlite
ENV EXECUTIONS_DATA_PRUNE=true
ENV EXECUTIONS_DATA_MAX_AGE=72
ENV EXECUTIONS_DATA_SAVE_ON_ERROR=all
ENV EXECUTIONS_DATA_SAVE_ON_SUCCESS=none
ENV EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=true
ENV NODE_OPTIONS=--max-old-space-size=2048
ENV N8N_DIAGNOSTICS_ENABLED=false
ENV N8N_VERSION_NOTIFICATIONS_ENABLED=false
ENV N8N_TEMPLATES_ENABLED=true
ENV N8N_HIRING_BANNER_ENABLED=false
ENV N8N_PERSONALIZATION_ENABLED=false

# سكربت التشغيل
COPY --chmod=755 <<EOF /start.sh
#!/bin/bash
set -e

echo "VIRAL EMPIRE v8.0 - Starting..."
echo "n8n: \$(n8n --version)"
echo "Node.js: \$(node --version)"
echo "FFmpeg: \$(ffmpeg -version 2>&1 | head -1)"
echo "yt-dlp: \$(yt-dlp --version)"
echo "aria2: \$(aria2c --version | head -1)"

echo "Updating yt-dlp..."
yt-dlp -U || echo "yt-dlp already latest"

echo "Starting n8n..."
exec n8n start
EOF

EXPOSE 5678
USER node
WORKDIR /home/node
CMD ["/start.sh"]
