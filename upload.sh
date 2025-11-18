#!/bin/bash
# Quick upload script for OpenNeuro
# Usage: ./upload.sh /path/to/your/data

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}OpenNeuro Docker Uploader${NC}"
echo "================================"
echo ""

# Check if data path is provided
if [ -z "$1" ]; then
    echo -e "${RED}ERROR: Data path not provided${NC}"
    echo ""
    echo "Usage: ./upload.sh /path/to/your/data [dataset-id]"
    echo ""
    echo "Examples:"
    echo "  ./upload.sh ./my-dataset"
    echo "  ./upload.sh ./my-dataset ds001234"
    echo ""
    exit 1
fi

DATA_PATH="$1"
DATASET_ID="$2"

# Check if data path exists
if [ ! -d "$DATA_PATH" ]; then
    echo -e "${RED}ERROR: Data path does not exist: $DATA_PATH${NC}"
    exit 1
fi

# Check for .env file
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}WARNING: .env file not found${NC}"
    echo "Creating .env from .env.example..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${YELLOW}Please edit .env and add your OPENNEURO_API_KEY${NC}"
        exit 1
    else
        echo -e "${RED}ERROR: .env.example not found${NC}"
        exit 1
    fi
fi

# Load environment variables
source .env

# Check for API key
if [ -z "$OPENNEURO_API_KEY" ] || [ "$OPENNEURO_API_KEY" = "your_api_key_here" ]; then
    echo -e "${RED}ERROR: OPENNEURO_API_KEY not set in .env file${NC}"
    echo "Please edit .env and add your API key from https://openneuro.org/keygen"
    exit 1
fi

# Build the Docker image
echo -e "${GREEN}Building Docker image...${NC}"
docker build -t openneuro-uploader:latest .

# Prepare the upload command
UPLOAD_CMD="deno run --allow-all https://deno.land/x/openneuro/cli.ts upload /upload"

if [ ! -z "$DATASET_ID" ]; then
    UPLOAD_CMD="$UPLOAD_CMD --dataset-id $DATASET_ID"
fi

echo ""
echo -e "${GREEN}Starting upload...${NC}"
echo "Data path: $DATA_PATH"
if [ ! -z "$DATASET_ID" ]; then
    echo "Dataset ID: $DATASET_ID"
fi
echo ""

# Run the Docker container
docker run --rm \
    -e OPENNEURO_API_KEY="$OPENNEURO_API_KEY" \
    -e OPENNEURO_URL="${OPENNEURO_URL:-https://openneuro.org}" \
    -v "$(realpath "$DATA_PATH"):/upload:ro" \
    openneuro-uploader:latest \
    sh -c "$UPLOAD_CMD"

echo ""
echo -e "${GREEN}Upload completed!${NC}"
