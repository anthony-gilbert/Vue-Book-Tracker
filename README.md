# Vue Book Tracker

A modern book tracking application built with Vue.js frontend and Go backend, featuring a clean tabbed interface for managing your reading lists.

## Features

- **Three Reading States**: Organize books into "To Read", "Currently Reading", and "Books Read"
- **Modern UI**: Clean, responsive design with Material Design components and gradient backgrounds
- **Tabbed Interface**: Easy navigation between different book categories
- **Real-time Updates**: Add, remove, and update books instantly
- **RESTful API**: Go backend with proper HTTP status codes and JSON responses
- **Containerized**: Docker support for both frontend and backend
- **Kubernetes Ready**: Complete K8s deployment configurations

## Quick Start

### Development

1. **Frontend Development**:
   ```bash
   npm install
   npm run serve
   # Runs on http://localhost:5001
   ```

2. **Backend Development**:
   ```bash
   cd backend
   go mod tidy
   go run cmd/server/main.go
   # Runs on http://localhost:8083
   ```

### Docker

```bash
# Build and run with Docker Compose
docker-compose up --build

# Access the application at http://localhost:3000
```

### Kubernetes

```bash
# Apply all configurations
kubectl apply -f kube-configs/

# Access via ingress at http://booktracker.dev
```

## Architecture

### Frontend (Vue.js)
- **Vue 2.6.11** with Vue CLI
- **Vue Material** for UI components
- **Vuex** for state management
- **Bootstrap** for additional styling
- **Nginx** for production serving

### Backend (Go)
- **Gin** web framework
- **CORS** middleware for cross-origin requests
- **UUID** generation for unique book IDs
- **In-memory database** (easily replaceable with persistent storage)
- **Health check** endpoint for monitoring

### Infrastructure
- **Docker** containers for both services
- **Kubernetes** deployments with health checks
- **Nginx Ingress** for routing and load balancing
- **Resource limits** and **horizontal scaling** ready

## API Documentation

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/books` | Get all books or filter by status |
| POST | `/api/v1/books` | Create a new book |
| PUT | `/api/v1/books/:id/status` | Update book status |
| DELETE | `/api/v1/books/:id` | Delete a book |
| GET | `/health` | Health check |

### Book Status Values
- `to-read` - Books you want to read
- `reading` - Books you're currently reading
- `read` - Books you've finished reading

## Development

### Bug Fixes Applied
- ✅ Fixed TypeScript/JavaScript inconsistencies
- ✅ Added proper props validation
- ✅ Removed unused Footer component
- ✅ Fixed Material Design component imports
- ✅ Improved error handling and user feedback

### UI Improvements
- ✅ Modern gradient backgrounds
- ✅ Tabbed interface for better organization
- ✅ Responsive design for mobile devices
- ✅ Clean card-based layouts
- ✅ Consistent color scheme and typography
- ✅ Empty state messages with icons

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test both frontend and backend
5. Submit a pull request

## License

MIT License - see LICENSE file for details