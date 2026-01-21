# ═══════════════════════════════════════════════════════════════════════════════
# 🏰 VIRAL EMPIRE v8.0 - ULTIMATE ADVANCED EDITION
# آخر تحديث: يناير 2026
# متوافق مع ClawCloud Run • Hugging Face Spaces • Railway • Render • أي منصة Docker
# ═══════════════════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════════════════
# 🐳 Base Image - Node.js 20 LTS (Debian Bookworm Slim لتثبيت FFmpeg كامل بسهولة)
# ═══════════════════════════════════════════════════════════════════════════════
FROM node:20-bookworm-slim

# ═══════════════════════════════════════════════════════════════════════════════
# 📋 معلومات الـ Image
# ═══════════════════════════════════════════════════════════════════════════════
LABEL maintainer="Viral Empire Team (Enhanced by Grok)"
LABEL version="8.0"
LABEL description="n8n Automation Platform with Full FFmpeg 6.x • yt-dlp Latest • aria2 • Arabic Fonts • Optimized for Video Automation"

# ═══════════════════════════════════════════════════════════════════════════════
# 🔧 متغيرات البناء
# ═══════════════════════════════════════════════════════════════════════════════
ARG DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# ═══════════════════════════════════════════════════════════════════════════════
# 📦 تثبيت الأدوات الأساسية
# ═══════════════════════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    gnupg \
    bash \
    coreutils \
    procps \
    && rm -rf /var/lib/apt/lists/*

# ═══════════════════════════════════════════════════════════════════════════════
# 🎬 تثبيت FFmpeg 6.x (أحدث إصدار مستقر كامل)
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
# ⬇️ تثبيت yt-dlp (أحدث إصدار) + aria2 (لتحميل متعدد الاتصالات - أسرع بكثير)
# ═══════════════════════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    aria2 \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --break-system-packages --no-cache-dir yt-dlp \
    && yt-dlp --version

# ═══════════════════════════════════════════════════════════════════════════════
# 🔧 تثبيت الأدوات المساعدة المتقدمة
# ═══════════════════════════════════════════════════════════════════════════════
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
    atomicparsley \    # إضافة جديدة: لتعديل metadata الفيديوهات (مفيد للفيرال)
    && rm -rf /var/lib/apt/lists/*

# ═══════════════════════════════════════════════════════════════════════════════
# 🔤 تثبيت الخطوط العربية الكاملة + إيموجي
# ═══════════════════════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    fontconfig \
    fonts-dejavu-core \
    fonts-liberation \
    fonts-noto-core \
    fonts-noto-extra \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    fonts-arabic \     # إضافة جديدة: خطوط عربية أفضل
    && fc-cache -f -v \
    && rm -rf /var/lib/apt/lists/*

# ═══════════════════════════════════════════════════════════════════════════════
# 📁 إنشاء المجلدات والصلاحيات
# ═══════════════════════════════════════════════════════════════════════════════
RUN mkdir -p /tmp/videos && chmod 1777 /tmp/videos \
    && mkdir -p /data && chmod 777 /data \
    && mkdir -p /home/node/.n8n && chown -R node:node /home/node \
    && mkdir -p /downloads && chmod 777 /downloads   # مجلد جديد للتحميلات

# ═══════════════════════════════════════════════════════════════════════════════
# 📦 تثبيت n8n (أحدث إصدار)
# ═══════════════════════════════════════════════════════════════════════════════
RUN npm install -g n8n@latest --omit=dev \
    && n8n --version \
    && npm cache clean --force

# ═══════════════════════════════════════════════════════════════════════════════
# 🌍 المنطقة الزمنية (مخصصة للسعودية/الشرق الأوسط)
# ═══════════════════════════════════════════════════════════════════════════════
ENV TZ=Asia/Riyadh
ENV GENERIC_TIMEZONE=Asia/Riyadh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# ═══════════════════════════════════════════════════════════════════════════════
# ⚙️ إعدادات n8n الأساسية والمتقدمة
# ═══════════════════════════════════════════════════════════════════════════════
ENV N8N_PORT=5678
ENV N8N_HOST=0.0.0.0
ENV N8N_PROTOCOL=https
ENV N8N_LOG_LEVEL=info

# فتح كامل للـ Code Node (مهم للأتمتة المتقدمة)
ENV NODE_FUNCTION_ALLOW_BUILTIN=*
ENV NODE_FUNCTION_ALLOW_EXTERNAL=*
ENV N8N_BLOCK_ENV_ACCESS_IN_NODE=false
ENV EXECUTIONS_PROCESS=main

# قاعدة البيانات
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/data/database.sqlite

# تنظيف تلقائي محسن
ENV EXECUTIONS_DATA_PRUNE=true
ENV EXECUTIONS_DATA_MAX_AGE=72          # زيادة إلى 72 ساعة
ENV EXECUTIONS_DATA_SAVE_ON_ERROR=all
ENV EXECUTIONS_DATA_SAVE_ON_SUCCESS=none
ENV EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=true

# أداء محسن
ENV NODE_OPTIONS="--max-old-space-size=2048"   # زيادة الذاكرة لمعالجة فيديوهات كبيرة
ENV N8N_DIAGNOSTICS_ENABLED=false
ENV N8N_VERSION_NOTIFICATIONS_ENABLED=false
ENV N8N_TEMPLATES_ENABLED=true
ENV N8N_HIRING_BANNER_ENABLED=false
ENV N8N_PERSONALIZATION_ENABLED=false

# ═══════════════════════════════════════════════════════════════════════════════
# 📝 سكربت التشغيل المتطور (مع تحديث yt-dlp تلقائي)
# ═══════════════════════════════════════════════════════════════════════════════
COPY --chmod=755 <<EOF /start.sh
#!/bin/bash
set -e

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         🏰 VIRAL EMPIRE v8.0 - GOD MODE ACTIVATED             ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  📦 Installed Tools:                                          ║"
echo "║  ├─ n8n:      \$(n8n --version 2>/dev/null || echo 'loading')"
echo "║  ├─ Node.js:  \$(node --version)"
echo "║  ├─ FFmpeg:   \$(ffmpeg -version 2>&1 | head -1 | cut -d' ' -f3)"
echo "║  ├─ yt-dlp:   \$(yt-dlp --version)"
echo "║  ├─ aria2:    \$(aria2c --version | head -1)"
echo "║  └─ Python:   \$(python3 --version | cut -d' ' -f2)"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  💾 Storage:  /tmp: \$(df -h /tmp | tail -1 | awk '{print \$4}') | /data: \$(df -h /data 2>/dev/null || echo 'N/A')"
echo "║  🌍 Timezone: \$TZ"
echo "║  🔌 Port:     \$N8N_PORT"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

echo "🔄 Updating yt-dlp to latest version..."
yt-dlp -U || echo "yt-dlp update skipped (already latest)"

echo ""
echo "🚀 Starting n8n in production mode..."
echo ""

exec n8n start
EOF

# ═══════════════════════════════════════════════════════════════════════════════
# 🏁 الإعدادات النهائية
# ═══════════════════════════════════════════════════════════════════════════════
EXPOSE 5678

USER node
WORKDIR /home/node

CMD ["/start.sh"]
