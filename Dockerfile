# ════════════════════════════════════════════════════════════════
# 🚀 VIRAL EMPIRE - CLOUD RUN EDITION
# أساس: الصورة الرسمية لـ n8n
# ════════════════════════════════════════════════════════════════
FROM docker.n8n.io/n8nio/n8n:latest

# ════════════════════════════════════════════════════════════════
# 📦 تثبيت أدوات الفيديو والصوت (كمدير للنظام)
# ════════════════════════════════════════════════════════════════
USER root

# تحديث وتثبيت الحزم الأساسية دفعة واحدة (أكثر كفاءة)
RUN apt-get update && apt-get install -y --no-install-recommends \
    # FFmpeg لمعالجة الفيديو/الصوت ومكتبات مساعدة
    ffmpeg \
    # Python 3 وأداة التثبيت pip
    python3 \
    python3-pip \
    # أدوات مساعدة للشبكة والتحميل
    curl \
    wget \
    # تنظيف الذاكرة المؤقتة لتقليل حجم الصورة
    && rm -rf /var/lib/apt/lists/*

# تثبيت yt-dlp (أحدث إصدار) باستخدام pip
RUN pip3 install --break-system-packages --no-cache-dir yt-dlp

# ════════════════════════════════════════════════════════════════
# ⚙️ إعدادات n8n الأساسية والإضافية
# ════════════════════════════════════════════════════════════════
# المنفذ الافتراضي لـ n8n (مهم!)
ENV N8N_PORT=5678
ENV N8N_HOST=0.0.0.0
EXPOSE 5678

# المنطقة الزمنية
ENV TZ=Asia/Riyadh
ENV GENERIC_TIMEZONE=Asia/Riyadh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 🔐 مفتاح التشفير (مهم جداً للأمان - اقرأ الشرح أدناه)
# استبدل النص بين علامتي التنصيص بمفتاحك القوي الخاص.
ENV N8N_ENCRYPTION_KEY="a5j8F!kL9$pQrS2vX8zYbG3mN6cR7tT1wE4dH"

# صلاحيات تنفيذ الأوامر والبرامج الخارجية (ضرورية لكوداتك)
ENV N8N_BLOCK_ENV_ACCESS_IN_NODE=false
ENV NODE_FUNCTION_ALLOW_BUILTIN=*
ENV NODE_FUNCTION_ALLOW_EXTERNAL=*
ENV EXECUTIONS_PROCESS=main

# تحسين أداء الذاكرة لـ Node.js
ENV NODE_OPTIONS="--max-old-space-size=2048"

# ════════════════════════════════════════════════════════════════
# 📁 إعداد مجلدات العمل المؤقتة
# ════════════════════════════════════════════════════════════════
RUN mkdir -p /tmp/videos && chmod 1777 /tmp

# ════════════════════════════════════════════════════════════════
# 📝 سكربت البدء (مبسط)
# ════════════════════════════════════════════════════════════════
COPY <<EOF /home/node/start.sh
#!/bin/bash
echo ""
echo "🚀 VIRAL EMPIRE - CLOUD RUN EDITION"
echo "📦 الأدوات المثبتة:"
echo "  • n8n: \$(n8n --version 2>/dev/null || echo 'جاهز')"
echo "  • FFmpeg: \$(ffmpeg -version 2>&1 | head -1 | awk '{print \$3}')"
echo "  • yt-dlp: \$(yt-dlp --version)"
echo ""
echo "🌍 المنطقة: \$TZ | 🔌 المنفذ: \$N8N_PORT"
echo "⏳ جاري التشغيل..."
exec n8n start
EOF

RUN chmod +x /home/node/start.sh

# ════════════════════════════════════════════════════════════════
# 🔄 العودة لمستخدم n8n العادي والتشغيل
# ════════════════════════════════════════════════════════════════
USER node
WORKDIR /home/node
CMD ["bash", "/home/node/start.sh"]
