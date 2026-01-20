FROM docker.n8n.io/n8nio/n8n:latest

USER root

# تثبيت ffmpeg و python و أدوات النظام
RUN apk add --no-cache \
    ffmpeg \
    python3 \
    py3-pip \
    ca-certificates \
    bash \
    curl

# إعداد بيئة بايثون وتثبيت yt-dlp
# يتم إنشاء بيئة افتراضية لتجنب تحذيرات النظام
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# تثبيت yt-dlp وتحديثه لأخر نسخة
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir yt-dlp

# التأكد من صلاحيات التنفيذ للمجلدات المؤقتة (لحل مشكلة العقد الحمراء)
RUN mkdir -p /tmp/n8n_files && chmod 777 /tmp/n8n_files

# العودة للمستخدم node للأمان
USER node

# إعدادات البيئة لـ ClawCloud
ENV N8N_PORT=5678
ENV GENERIC_TIMEZONE=Asia/Riyadh
ENV TZ=Asia/Riyadh
