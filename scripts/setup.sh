#!/bin/bash

# DeepSeek Local Setup Script
# Configure and start DeepSeek environment with Docker

set -e  # Stop on first error

echo "🚀 Setting up DeepSeek Local..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Install Docker first."
    echo "👉 https://docs.docker.com/engine/install/"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose not found."
    exit 1
fi

# Create scripts directory if it doesn't exist
mkdir -p scripts

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found. Create it first!"
    exit 1
fi

# Load variables from .env
source .env

echo "📦 Starting containers..."
docker-compose up -d

echo "⏳ Waiting for Ollama to initialize..."
sleep 10

# Check if Ollama is working
echo "🔍 Checking if Ollama is running..."
if curl -s http://localhost:${OLLAMA_PORT}/api/tags > /dev/null; then
    echo "✅ Ollama is running!"
else
    echo "❌ Ollama is not responding. Check the logs:"
    echo "   docker-compose logs ollama"
    exit 1
fi

# Install default models if specified
if [ ! -z "$DEFAULT_MODELS" ]; then
    echo "📥 Installing models: $DEFAULT_MODELS"
    ./scripts/install-models.sh
fi

echo ""
echo "🎉 Setup completed!"
echo ""
echo "📍 Access:"
echo "   Ollama API: http://localhost:${OLLAMA_PORT}"
echo "   Web Interface: http://localhost:${WEBUI_PORT}"
echo ""
echo "🛠️  Useful commands:"
echo "   docker-compose logs -f        # View logs"
echo "   docker-compose stop           # Stop"
echo "   docker-compose down           # Stop and remove"
echo "   ./scripts/install-models.sh   # Install more models"
echo ""