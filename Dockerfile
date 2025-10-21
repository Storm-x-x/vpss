FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Ubuntu 22.04 has Python 3.10 by default, let's install 3.12 quickly
RUN apt-get update && apt-get install -y \
    openssh-server \
    wget \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update && apt-get install -y python3.12 python3.12-venv \
    && apt-get clean

# Install pip and make python3 point to 3.12
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python3.12 get-pip.py \
    && rm get-pip.py \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Install ngrok
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz \
    && tar xzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin \
    && chmod +x /usr/local/bin/ngrok

RUN echo 'root:Darkboy336' | chpasswd

RUN mkdir -p /var/run/sshd \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

RUN ngrok config add-authtoken 34914Ptd48gbHXPmcNYxWEXCxpu_3V4itphQ1buQFCVEn8C1h

RUN echo "Dark" > /etc/hostname

EXPOSE 22

CMD bash -c "echo '127.0.0.1 Dark' >> /etc/hosts && hostname Dark && /usr/sbin/sshd -D & ngrok tcp 22 --log=stdout"
