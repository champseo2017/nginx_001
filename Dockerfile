# เริ่มต้นจาก Alpine Linux เวอร์ชั่นล่าสุด เพื่อขนาดที่เล็กที่สุด
FROM nginx:alpine

# ตั้งค่าผู้ดูแลระบบ
LABEL maintainer="your-email@example.com"

# สร้างโฟลเดอร์ที่จำเป็นและกำหนดสิทธิ์
RUN mkdir -p /var/cache/nginx \
    && mkdir -p /var/log/nginx \
    && mkdir -p /etc/nginx/conf.d \
    && mkdir -p /usr/share/nginx/html \
    && chown -R nginx:nginx /var/cache/nginx \
    && chown -R nginx:nginx /var/log/nginx

# ตั้งค่า timezone เป็นประเทศไทย
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Bangkok /etc/localtime \
    && echo "Asia/Bangkok" > /etc/timezone \
    && apk del tzdata

# คัดลอกไฟล์คอนฟิกของ NGINX จากโฟลเดอร์ config
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/default.conf /etc/nginx/conf.d/default.conf

# เปิด port 80 สำหรับ HTTP
EXPOSE 80

# สร้างโฟลเดอร์สำหรับเว็บไซต์และคัดลอกไฟล์
WORKDIR /usr/share/nginx/html
COPY ./html/ .

# กำหนดสิทธิ์ไฟล์ทั้งหมดให้กับ nginx user
RUN chown -R nginx:nginx /usr/share/nginx/html \
    && chmod -R 755 /usr/share/nginx/html \
    && chown -R nginx:nginx /etc/nginx/conf.d \
    && chown -R nginx:nginx /etc/nginx/nginx.conf \
    && chmod 644 /usr/share/nginx/html/*.html

# สั้งค่าให้ทำงานในโหมด non-daemon
CMD ["nginx", "-g", "daemon off;"]

# สลับไปใช้ผู้ใช้ nginx แทน root
USER nginx