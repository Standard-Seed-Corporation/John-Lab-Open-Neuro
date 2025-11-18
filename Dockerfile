# Dockerfile for OpenNeuro Upload
# This container uses Deno to run the OpenNeuro CLI for uploading datasets

FROM denoland/deno:1.38.5

# Set working directory
WORKDIR /app

# Install OpenNeuro CLI using Deno
RUN deno install --allow-all --unstable --name openneuro https://deno.land/x/openneuro/cli.ts || \
    deno install --allow-all --name openneuro https://raw.githubusercontent.com/OpenNeuroOrg/openneuro/master/packages/openneuro-cli/src/index.ts || \
    echo "OpenNeuro CLI will be installed at runtime"

# Add Deno bin to PATH
ENV PATH="/root/.deno/bin:${PATH}"

# Create upload directory
RUN mkdir -p /upload

# Set the upload directory as a volume
VOLUME ["/upload"]

# Set environment variables for OpenNeuro
ENV OPENNEURO_URL="https://openneuro.org"

# Create entrypoint script
RUN echo '#!/bin/sh\n\
if [ -z "$OPENNEURO_API_KEY" ]; then\n\
  echo "ERROR: OPENNEURO_API_KEY environment variable is required"\n\
  echo "Please set it with: -e OPENNEURO_API_KEY=your_api_key"\n\
  exit 1\n\
fi\n\
\n\
if [ ! -d "/upload" ] || [ -z "$(ls -A /upload)" ]; then\n\
  echo "ERROR: /upload directory is empty or not mounted"\n\
  echo "Please mount your data directory with: -v /path/to/data:/upload"\n\
  exit 1\n\
fi\n\
\n\
echo "Starting OpenNeuro upload..."\n\
echo "Upload directory: /upload"\n\
echo "Dataset contents:"\n\
ls -lah /upload\n\
echo ""\n\
\n\
# Install OpenNeuro CLI if not already installed\n\
if ! command -v openneuro >/dev/null 2>&1; then\n\
  echo "Installing OpenNeuro CLI..."\n\
  deno install --allow-all --name openneuro https://deno.land/x/openneuro/cli.ts || \\\n\
  deno install --allow-all --name openneuro https://raw.githubusercontent.com/OpenNeuroOrg/openneuro/master/packages/openneuro-cli/src/index.ts\n\
fi\n\
\n\
# Run the upload command\n\
exec "$@"\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# Default command - can be overridden
CMD ["deno", "run", "--allow-all", "https://deno.land/x/openneuro/cli.ts", "upload", "/upload"]
