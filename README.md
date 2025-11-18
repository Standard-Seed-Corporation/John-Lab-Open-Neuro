# John-Lab-Open-Neuro

Docker-based solution for uploading neuroimaging datasets to OpenNeuro using the OpenNeuro CLI with Deno.

## Overview

This repository provides a simple Docker container that uses the OpenNeuro CLI (running on Deno) to upload BIDS-formatted neuroimaging datasets to [OpenNeuro.org](https://openneuro.org). With just one command, you can upload your dataset without installing Deno or the OpenNeuro CLI locally.

## Prerequisites

- Docker installed on your system
- An OpenNeuro account and API key (get one at https://openneuro.org/keygen)
- A BIDS-formatted dataset ready for upload

## Quick Start

### 1. Clone this repository

```bash
git clone https://github.com/Standard-Seed-Corporation/John-Lab-Open-Neuro.git
cd John-Lab-Open-Neuro
```

### 2. Set up your API key

Copy the example environment file and add your OpenNeuro API key:

```bash
cp .env.example .env
```

Edit `.env` and replace `your_api_key_here` with your actual API key from https://openneuro.org/keygen

### 3. Upload your data

**Option A: Using the upload script (easiest)**

```bash
./upload.sh /path/to/your/dataset
```

Or with a specific dataset ID:

```bash
./upload.sh /path/to/your/dataset ds001234
```

**Option B: Using Docker directly**

Build the image:

```bash
docker build --platform linux/arm64 -t openneuro-uploader:latest
```

Run the upload:

```bash
docker run --rm \
  -e OPENNEURO_API_KEY="your_api_key_here" \
  -v /path/to/your/dataset:/upload:ro \
  openneuro-uploader:latest
```

**Option C: Using Docker Compose**

1. Edit `docker-compose.yml` and update the volumes section with your data path
2. Run:

```bash
docker-compose up
```

## Configuration

### Environment Variables

- `OPENNEURO_API_KEY` (required): Your OpenNeuro API key
- `OPENNEURO_URL` (optional): OpenNeuro instance URL (defaults to https://openneuro.org)

### Custom Upload Commands

You can pass custom arguments to the OpenNeuro CLI:

```bash
docker run --rm \
  -e OPENNEURO_API_KEY="your_api_key_here" \
  -v /path/to/your/dataset:/upload:ro \
  openneuro-uploader:latest \
  deno run --allow-all https://deno.land/x/openneuro/cli.ts upload /upload --dataset-id ds001234
```

## Directory Structure

```
.
├── Dockerfile              # Docker image definition
├── docker-compose.yml      # Docker Compose configuration
├── upload.sh              # Quick upload script
├── .env.example           # Example environment file
├── .dockerignore          # Docker ignore patterns
├── upload-example/        # Example upload directory structure
└── README.md             # This file
```

## BIDS Format

Your dataset should follow the Brain Imaging Data Structure (BIDS) format. For more information:
- BIDS Specification: https://bids.neuroimaging.io/
- BIDS Validator: https://bids-standard.github.io/bids-validator/

## OpenNeuro CLI Documentation

For more information about the OpenNeuro CLI and available commands:
- https://docs.openneuro.org/packages/openneuro-cli.html

## Security Notes

- Never commit your `.env` file or API keys to version control
- The upload directory is mounted as read-only (`:ro`) to prevent accidental modifications
- Your data is uploaded directly to OpenNeuro and is not stored in the Docker image

## Troubleshooting

### API Key Issues

If you get an API key error, ensure:
1. You've created a `.env` file from `.env.example`
2. You've added your valid API key from https://openneuro.org/keygen
3. The API key is not expired

### Upload Directory Issues

If you get an empty directory error:
1. Verify the path to your dataset is correct
2. Ensure the directory contains BIDS-formatted data
3. Check that you have read permissions on the directory

### Docker Issues

If Docker commands fail:
1. Ensure Docker is running
2. Check that you have permissions to run Docker commands
3. Try rebuilding the image: `docker build -t openneuro-uploader:latest .`

## Contributing

Issues and pull requests are welcome! Please ensure any changes maintain the simplicity and ease of use of the one-command upload process.

## License

This project is provided as-is for use with OpenNeuro.

## References

- OpenNeuro: https://openneuro.org
- OpenNeuro CLI: https://docs.openneuro.org/packages/openneuro-cli.html
- Deno: https://deno.land
- BIDS: https://bids.neuroimaging.io/
