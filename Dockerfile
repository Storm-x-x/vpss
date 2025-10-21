FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openssh-server \
      wget \
      curl && \
    rm -rf /var/lib/apt/lists/*

# Setup SSH
RUN echo 'root:Darkboy336' | chpasswd && \
    mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Install ngrok
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O - | tar xz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/ngrok

# Configure ngrok token
RUN ngrok config add-authtoken "34914Ptd48gbHXPmcNYxWEXCxpu_3V4itphQ1buQFCVEn8C1h"

# Set hostname
RUN echo "Dark" > /etc/hostname

EXPOSE 22

# Start services
CMD /usr/sbin/sshd && ngrok tcp 22 --log=stdout
