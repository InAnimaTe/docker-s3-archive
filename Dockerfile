# Modern, slim base
FROM debian:bookworm-slim

# Set noninteractive to avoid tz/locale prompts
ENV DEBIAN_FRONTEND=noninteractive
# Add AWS CLI v2 to PATH
ENV PATH="/usr/local/aws-cli/v2/current/bin:${PATH}"

# Install only what we need:
# - bash: your script uses #!/bin/bash
# - gnupg: for encryption
# - xz-utils: compression
# - tar: archiving (explicit for clarity)
# - curl, unzip, ca-certificates: to fetch & install AWS CLI v2 securely
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash gnupg xz-utils tar \
      curl unzip ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2 (no Python; self-contained)
# NOTE: You can pin a version by setting AWSCLI_VERSION (e.g., 2.17.56)
ARG AWSCLI_VERSION=latest
RUN set -eux; \
    tmpdir="$(mktemp -d)"; \
    cd "$tmpdir"; \
    if [ "$AWSCLI_VERSION" = "latest" ]; then \
      curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip; \
    else \
      curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" -o awscliv2.zip; \
    fi; \
    unzip -q awscliv2.zip; \
    ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli; \
    cd /; rm -rf "$tmpdir"

# (Optional) create a non-root user for better security
# Uncomment if you prefer running as non-root:
# RUN useradd -r -u 10001 -g nogroup appuser
# USER appuser

# App workspace (if you copy your script in the image)
WORKDIR /app

# If your backup script is in the same directory as this Dockerfile:
# COPY backup.sh /usr/local/bin/backup.sh
# RUN chmod +x /usr/local/bin/backup.sh
# Default command (adjust if you place the script elsewhere)
# CMD ["/usr/local/bin/backup.sh"]
## Add in our main run script.
ADD run /app/run

## Disabling for now until I get this working.
#ADD restore /app/restore

# If you want to use a config, rename s3cfg.example to s3cfg
#ADD s3cfg /root/.aws/config

RUN chmod +x /app/run
#RUN chmod +x /app/restore

CMD ["/app/run"]
