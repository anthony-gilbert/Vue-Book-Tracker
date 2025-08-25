#!/bin/bash

echo "🚀 Vue Book Tracker - Backend Server"
echo "===================================="
echo ""
echo "Starting backend server on port 8083..."
echo "Keep this terminal open!"
echo ""
echo "To stop the server: Press Ctrl+C"
echo ""

cd /home/nova/Development/Vue-Book-Tracker/backend
export PORT=8083
exec ./book-tracker-server