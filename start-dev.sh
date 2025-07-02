#!/bin/bash

echo "Starting AutoStand development environment..."

# Start the proxy server in the background
echo "Starting proxy server..."
cd proxy-server
npm install
npm start &
PROXY_PID=$!

# Wait for proxy server to start
sleep 2

# Start Flutter web app
echo "Starting Flutter web app..."
cd ..
flutter run -d chrome

# When Flutter exits, kill the proxy server
kill $PROXY_PID
echo "Development environment stopped."