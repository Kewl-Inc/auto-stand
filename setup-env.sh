#!/bin/bash

echo "🔧 AutoStand Environment Setup"
echo "=============================="
echo ""

# Check if .env exists
if [ -f .env ]; then
    echo "⚠️  .env file already exists. Backing up to .env.backup"
    cp .env .env.backup
fi

# Copy from example
cp .env.example .env

echo "✅ Created .env file from .env.example"
echo ""
echo "📝 Next steps:"
echo "1. Edit .env and add your OpenAI API key"
echo "2. Edit .env and add your Slack webhook URL"
echo "3. For the proxy server, also update proxy-server/.env"
echo ""
echo "Never commit .env files to version control!"