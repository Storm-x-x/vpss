FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install packages including gnupg for repository
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openssh-server \
      curl \
      wget \
      gnupg && \
    rm -rf /var/lib/apt/lists/*

# SSH setup
RUN echo 'root:Darkboy336' | chpasswd && \
    mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Install ngrok from official repository
RUN curl -fsSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list && \
    apt-get update && \
    apt-get install -y ngrok

# Configure ngrok
RUN ngrok config add-authtoken "34914Ptd48gbHXPmcNYxWEXCxpu_3V4itphQ1buQFCVEn8C1h"

# Set hostname
RUN echo "Dark" > /etc/hostname

EXPOSE 22

CMD ["sh", "-c", "/usr/sbin/sshd && ngrok tcp 22 --log=stdout"]
