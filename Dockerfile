# Use a lightweight Ubuntu 22.04 base image
FROM ubuntu:22.04

# Set environment variable to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV DEVOPS_BOT_HOME /var/devops-bot
ENV PATH="${PATH}:${DEVOPS_BOT_HOME}/bin"

# Create a non-root user for running the application
ARG user=devops-bot
ARG group=devops-bot
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group} \
    && useradd -m -u ${uid} -g ${group} -s /bin/bash ${user} \
    && mkdir -p $DEVOPS_BOT_HOME/logs

# Install necessary tools and clean up
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    git openssh-client curl bash python3 python3-pip openjdk-8-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR $DEVOPS_BOT_HOME

# Copy the installation script
COPY install.sh /usr/local/bin/install.sh
RUN chmod +x /usr/local/bin/install.sh

# Run the installation script
RUN /usr/local/bin/install.sh

# Set ownership to the non-root user
RUN chown -R ${user}:${group} $DEVOPS_BOT_HOME

# Expose the port for the UI
EXPOSE 4102

# Switch to non-root user
USER ${user}

# Set entrypoint and default command
ENTRYPOINT ["/usr/local/bin/dob"]
CMD ["run-ui", "--port", "4102"]
