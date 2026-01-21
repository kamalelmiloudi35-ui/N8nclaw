# ═══════════════════════════════════════════════════════════════════════════════
# 🏰 VIRAL EMPIRE v7.0 - ULTIMATE EDITION
# آخر تحديث: يناير 2025
# متوافق مع Hugging Face Spaces
# ═══════════════════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════════════════
# 🐳 Base Image - Node.js 20 LTS (الأكثر استقراراً)
# ═══════════════════════════════════════════════════════════════════════════════
FROM node:20-bookworm-slim

# ═══════════════════════════════════════════════════════════════════════════════
# 📋 معلومات الـ Image
# ═══════════════════════════════════════════════════════════════════════════════
LABEL maintainer="Viral Empire Team"
LABEL version="7.0"
LABEL description="n8n Automation Platform with FFmpeg & yt-dlp"

# ═══════════════════════════════════════════════════════════════════════════════
# 🔧 متغيرات البناء
# ═══════════════════════════════════════════════════════════════════════════════
ARG DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# ═══════════════════════════════════════════════════════════════════════════════
# 📦 تثبيت الأدوات الأساسية (المرحلة 1)
# ═══════════════════════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    # ═══ أدوات النظام الأساسية ═══
    ca-certificates \
    curl \
    wget \
    gnupg \
    bash \
    coreutils \
    procps \
    && rm -rf /var/lib/apt/lists/*

# ═══════════════════════════════════════════════════════════════════════════════
# 🎬 تثبيت FFmpeg 6.1 (أحدث إصدار مستقر)
# ═══════════════════════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && ffmpeg -version

# ═══════════════════════════════════════════════════════════════════════════════
# 🐍 تثبيت Python 3.11 + pip
# ═══════════════════════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    && rm -rf /var/lib/apt/lists/* \
    && python3 --version

# ═══════════════════════════════════════════════════════════════════════════════
# ⬇️ تثبيت yt-dlp (أحدث إصدار)
# ═══════════════════════════════════════════════════════════════════════════════
RUN pip3 install --break-system-packages --no-cache-dir \
    yt-dlp \
    && yt-dlp --version

# ═══════════════════════════════════════════════════════════════════════════════
# 🔧 تثبيت الأدوات المساعدة
# ═══════════════════════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    # معالجة JSON
    jq \
    # أدوات نصية
    sed \
    gawk \
    grep \
    # ضغط/فك الضغط
    zip \
    unzip \
    # فحص الملفات
    file \
    mediainfo \
    # حسابات
    bc \
    # أدوات إضافية
    git \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# ═══════════════════════════════════════════════════════════════════════════════
# 🔤 تثبيت الخطوط (للترجمات العربية)
# ═══════════════════════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    fontconfig \
    fonts-dejavu-core \
    fonts-liberation \
    fonts-noto-core \
    fonts-noto-color-emoji \
    # تحديث كاش الخطوط
    && fc-cache -f -v \
    && rm -rf /var/lib/apt/lists/*

# ═══════════════════════════════════════════════════════════════════════════════
# 📁 إنشاء المجلدات
# ═══════════════════════════════════════════════════════════════════════════════
RUN mkdir -p /tmp/videos && chmod 1777 /tmp/videos \
    && mkdir -p /data && chmod 777 /data \
    && mkdir -p /home/node/.n8n && chown -R node:node /home/node

# ═══════════════════════════════════════════════════════════════════════════════
# 📦 تثبيت n8n (أحدث إصدار)
# ═══════════════════════════════════════════════════════════════════════════════
RUN npm install -g n8n@latest --omit=dev \
    && n8n --version

# ═══════════════════════════════════════════════════════════════════════════════
# 🌍 المنطقة الزمنية
# ═══════════════════════════════════════════════════════════════════════════════
ENV TZ=Asia/Riyadh
ENV GENERIC_TIMEZONE=Asia/Riyadh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# ═══════════════════════════════════════════════════════════════════════════════
# ⚙️ إعدادات n8n الأساسية
# ═══════════════════════════════════════════════════════════════════════════════
ENV N8N_PORT=5678
ENV N8N_HOST=0.0.0.0
ENV N8N_PROTOCOL=https


# ═══════════════════════════════════════════════════════════════════════════════
# 🔓 صلاحيات Code Node (مهم جداً!)
# ═══════════════════════════════════════════════════════════════════════════════
ENV NODE_FUNCTION_ALLOW_BUILTIN=*
ENV NODE_FUNCTION_ALLOW_EXTERNAL=*
ENV N8N_BLOCK_ENV_ACCESS_IN_NODE=false
ENV EXECUTIONS_PROCESS=main

# ═══════════════════════════════════════════════════════════════════════════════
# 🗄️ قاعدة البيانات
# ═══════════════════════════════════════════════════════════════════════════════
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/data/database.sqlite

# ═══════════════════════════════════════════════════════════════════════════════
# 🧹 إعدادات التنظيف التلقائي
# ═══════════════════════════════════════════════════════════════════════════════
ENV EXECUTIONS_DATA_PRUNE=true
ENV EXECUTIONS_DATA_MAX_AGE=48
ENV EXECUTIONS_DATA_SAVE_ON_ERROR=all
ENV EXECUTIONS_DATA_SAVE_ON_SUCCESS=none
ENV EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=true

# ═══════════════════════════════════════════════════════════════════════════════
# 🚀 إعدادات الأداء
# ═══════════════════════════════════════════════════════════════════════════════
ENV NODE_OPTIONS="--max-old-space-size=1536"
ENV N8N_DIAGNOSTICS_ENABLED=false
ENV N8N_VERSION_NOTIFICATIONS_ENABLED=false
ENV N8N_TEMPLATES_ENABLED=true
ENV N8N_HIRING_BANNER_ENABLED=false
ENV N8N_PERSONALIZATION_ENABLED=false

# ═══════════════════════════════════════════════════════════════════════════════
# 📝 سكربت التشغيل
# ═══════════════════════════════════════════════════════════════════════════════
COPY --chmod=755 <<EOF /start.sh
#!/bin/bash
set -e

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         🏰 VIRAL EMPIRE v7.0 - GOD MODE                       ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  📦 Installed Tools:                                          ║"
echo "║  ├─ n8n:      \$(n8n --version 2>/dev/null || echo 'loading')"
echo "║  ├─ Node.js:  \$(node --version)"
echo "║  ├─ FFmpeg:   \$(ffmpeg -version 2>&1 | head -1 | cut -d' ' -f3)"
echo "║  ├─ yt-dlp:   \$(yt-dlp --version)"
echo "║  └─ Python:   \$(python3 --version | cut -d' ' -f2)"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  💾 Storage: \$(df -h /tmp | tail -1 | awk '{print \$4}') available in /tmp"
echo "║  🌍 Timezone: \$TZ"
echo "║  🔌 Port: \$N8N_PORT"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "🚀 Starting n8n..."
echo ""

exec n8n
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# 🏁 التشغيل النهائي
# ═══════════════════════════════════════════════════════════════════════════════
EXPOSE 7860
USER node
WORKDIR /home/node

CMD ["/start.sh"]
