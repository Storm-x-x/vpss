FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Kolkata

ARG NGROK_AUTHTOKEN="34O2jBhR4Tia0fYs0WSVYphSaux_2pbAqYJHz2F6rXWEnzLvD"
ARG ROOT_PASSWORD="Darkboy336"

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

# Simple startup
CMD ["sh", "-c", "/usr/sbin/sshd && ngrok config add-authtoken \"${NGROK_AUTHTOKEN}\" && echo \"🚀 Starting ngrok SSH tunnel...\" && ngrok tcp 22 --log=stdout"]
