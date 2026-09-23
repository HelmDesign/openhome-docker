#!/bin/bash

echo "🐳 OpenHome Docker Setup"
echo "======================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

echo "✅ Docker found: $(docker --version)"
echo ""

# Create saves directory
if [ ! -d "saves" ]; then
    echo "📁 Creating saves directory..."
    mkdir -p saves
    echo "✅ Created ./saves/"
fi

echo ""
echo "📝 Next steps:"
echo "1. Copy your Pokemon save files to ./saves/"
echo "2. Run: docker-compose up -d"
echo "3. Access OpenHome at: http://localhost:6080"
echo ""
echo "💡 Tip: You can also use 'docker build -t openhome-novnc .' for manual control"
echo ""