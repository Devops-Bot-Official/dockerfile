FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required tools
RUN apt-get update -y && \
    apt-get install -y wget python3-pip && \
    apt-get clean

# Copy the combined installation script
COPY /tmp/artifacts/install.sh /usr/local/bin/install.sh
RUN chmod +x /usr/local/bin/install.sh

# Run the installation script
RUN /usr/local/bin/install.sh

# Keep the container running
CMD ["tail", "-f", "/dev/null"]

