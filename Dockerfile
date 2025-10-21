FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Kolkata

# Use ENV for runtime, ARG for build-time (more secure)
ARG NGROK_AUTHTOKEN="30uRHNctHOB49qTaXJrPdjVb4aq_7dKNs7zAsLKJGzhfm14Pb"
ARG ROOT_PASSWORD="Darkboy336"

# Install minimal tools and tzdata
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils ca-certificates gnupg2 curl wget lsb-release tzdata && \
    ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

# Install common utilities, SSH, and software-properties-common for add-apt-repository
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openssh-server \
      wget \
      curl \
      git \
      nano \
      sudo \
      python3-pip \
      software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Python 3.12
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends python3.12 python3.12-venv && \
    rm -rf /var/lib/apt/lists/*

# Make python3 point to python3.12
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# SSH root password
RUN echo "root:${ROOT_PASSWORD}" | chpasswd \
    && mkdir -p /var/run/sshd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config || true \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config || true \
    && sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config || true

# ngrok official repo
RUN curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
    && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends ngrok \
    && rm -rf /var/lib/apt/lists/*

# Create ngrok config directory and add token with region
RUN mkdir -p /root/.config/ngrok && \
    if [ -n "${NGROK_AUTHTOKEN}" ]; then \
      ngrok config add-authtoken "${NGROK_AUTHTOKEN}" && \
      echo "region: ap" >> /root/.config/ngrok/ngrok.yml && \
      echo "web_addr: 0.0.0.0:4040" >> /root/.config/ngrok/ngrok.yml; \
    fi

# Optional hostname file
RUN echo "Dark" > /etc/hostname

# Force bash prompt
RUN echo 'export PS1="root@Dark:\\w# "' >> /root/.bashrc

EXPOSE 22 4040

# Start script that shows ngrok URL clearly
CMD ["sh", "-c", "
  # Start SSH daemon in background
  mkdir -p /var/run/sshd
  /usr/sbin/sshd &
  
  # Wait a moment for SSH to start
  sleep 3
  
  # Start ngrok and capture output
  echo '🚀 Starting ngrok tunnel...'
  echo '📡 Connecting to ngrok servers...'
  
  # Start ngrok in background and capture logs
  ngrok tcp 22 --region=ap --log=stdout > /var/log/ngrok.log 2>&1 &
  
  # Wait for ngrok to establish connection
  sleep 10
  
  # Show recent ngrok logs
  echo '=== NGROK CONNECTION STATUS ==='
  tail -20 /var/log/ngrok.log
  
  # Try to get tunnel info using ngrok API
  echo '=== TUNNEL INFORMATION ==='
  curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -o '"public_url":"[^"]*"' || echo 'Waiting for tunnel to establish...'
  
  echo '✅ SSH Server is running on port 22'
  echo '🔍 Ngrok web interface available on http://localhost:4040'
  echo '📝 Check /var/log/ngrok.log for detailed connection info'
  
  # Keep container running and show real-time logs
  tail -f /var/log/ngrok.log
"]
