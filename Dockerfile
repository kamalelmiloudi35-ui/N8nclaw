# استخدام نسخة n8n الرسمية
FROM docker.n8n.io/n8nio/n8n:latest

# التبديل للمستخدم الجذر لتثبيت الأدوات
USER root

# تحديث النظام وتثبيت ffmpeg و python
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    python3 \
    python3-pip \
    python3-venv \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# إنشاء بيئة افتراضية لبايثون وتثبيت yt-dlp (لتجنب تعارض النظام)
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# تثبيت وتحديث yt-dlp
RUN pip3 install --no-cache-dir --upgrade pip yt-dlp

# إعداد مجلد العمل والتأكد من الصلاحيات
RUN mkdir -p /tmp/n8n_files && chmod 777 /tmp/n8n_files

# العودة لمستخدم n8n الافتراضي
USER node

# إعدادات الوقت والمنفذ
ENV N8N_PORT=5678
ENV TZ=Asia/Riyadh
