# Vue Book Tracker - Quick Start Guide

## 🚀 How to Start the Application

### Step 1: Start the Backend Server
Open a terminal and run:
```bash
cd /home/nova/Development/Vue-Book-Tracker/backend
PORT=8083 ./book-tracker-server
```

Keep this terminal open - you should see:
```
[GIN-debug] Listening and serving HTTP on :8083
2025/08/25 08:14:53 Starting server on port 8083
```

### Step 2: Start the Frontend (in a new terminal)
```bash
cd /home/nova/Development/Vue-Book-Tracker
npm run serve
```

The frontend will run on http://localhost:5001

### Step 3: Test Registration
1. Open http://localhost:5001 in your browser
2. Click on the "Register" tab
3. Fill in:
   - Username: (at least 3 characters)
   - Email: valid email format
   - Password: (at least 6 characters)
4. Click "Register"

## 🔧 Troubleshooting

### If you see "Cannot connect to server":
1. Make sure the backend terminal is still running
2. Check that you see "Starting server on port 8083" in the backend terminal
3. Make sure no firewall is blocking port 8083

### If registration fails:
1. Check the browser console (F12 → Console) for detailed error messages
2. Check the backend terminal for any error logs
3. Try different username/email if you get "already exists" error

## 🐳 Alternative: Using Docker
If you prefer Docker:
```bash
docker-compose up --build
```
This will start both frontend and backend with SQLite persistence.