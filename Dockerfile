FROM rocker/tidyverse:latest

# Install system dependencies for Claude Code (Node.js)
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install the gt R package
RUN R -e "install.packages('gt', repos='https://cloud.r-project.org/')"

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Create non-root user for safe agent execution
# Check if group 1000 exists, if not create it, otherwise use existing
RUN if ! getent group 1000; then groupadd -r agent -g 1000; else groupmod -n agent $(getent group 1000 | cut -d: -f1); fi && \
    if ! getent passwd 1000; then useradd -r -u 1000 -g 1000 -m -s /bin/bash agent; else usermod -l agent -d /home/agent -m $(getent passwd 1000 | cut -d: -f1); fi

# Set working directory and change ownership
WORKDIR /workspace
RUN chown -R agent:agent /workspace

# Switch to non-root user
USER agent

# Set default command
CMD ["bash"]
