#!/bin/bash

echo "🌐 Vue Book Tracker - Frontend Server"
echo "====================================="
echo ""
echo "Starting frontend server..."
echo "Will be available at: http://localhost:5001"
echo ""
echo "To stop the server: Press Ctrl+C"
echo ""

cd /home/nova/Development/Vue-Book-Tracker
export NODE_OPTIONS=--openssl-legacy-provider
npm run serve