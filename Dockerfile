FROM jenkins/jenkins:lts-jdk17

# Build argument for Docker socket GID
ARG DOCKER_GID=1001

USER root

# Install Docker CLI
RUN apt-get update && \
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Create docker group with the specified GID and add jenkins user to it
# If a group with that GID already exists (e.g., "staff" on macOS), reuse it;
# otherwise create a dedicated group called docker-host.
RUN set -eux; \
    if getent group "${DOCKER_GID}" >/dev/null; then \
        group_name="$(getent group "${DOCKER_GID}" | cut -d: -f1)"; \
        echo "Using existing group $group_name (GID ${DOCKER_GID})"; \
        usermod -a -G "$group_name" jenkins; \
    else \
        echo "Creating group docker-host with GID ${DOCKER_GID}"; \
        groupadd -g "${DOCKER_GID}" docker-host; \
        usermod -a -G docker-host jenkins; \
    fi

USER jenkins
