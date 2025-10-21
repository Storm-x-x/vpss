FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Kolkata

# Remove ARG and use ENV for runtime
ENV NGROK_AUTHTOKEN="34914Ptd48gbHXPmcNYxWEXCxpu_3V4itphQ1buQFCVEn8C1h"
ENV ROOT_PASSWORD="Darkboy336"

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      wget \
      openssh-server \
      python3 \
      python3-pip \
      tzdata && \
    ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

# SSH setup
RUN echo "root:${ROOT_PASSWORD}" | chpasswd && \
    mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Install ngrok using direct download
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O - | tar xz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/ngrok

# Set hostname and prompt
RUN echo "Dark" > /etc/hostname && \
    echo 'export PS1="root@Dark:\\w# "' >> /root/.bashrc

EXPOSE 22

# Create startup script that uses the ENV variable
RUN cat > /start.sh << 'EOF'
#!/bin/bash
echo "🔧 Configuring ngrok with token..."
ngrok config add-authtoken "$NGROK_AUTHTOKEN"

echo "🚀 Starting SSH server..."
/usr/sbin/sshd

echo "🌐 Starting ngrok tunnel..."
exec ngrok tcp 22 --log=stdout
EOF

RUN chmod +x /start.sh

CMD ["/start.sh"]
