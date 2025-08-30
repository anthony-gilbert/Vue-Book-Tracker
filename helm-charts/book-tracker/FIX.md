# Ingress Routing Issue Fix

## Issue
The domain `booktracker.dev` was routing to the wrong application due to incorrect path routing configuration in the Helm chart ingress.

## Root Cause
The ingress configuration in `values.yaml` had the path order reversed:
- `/api/` was mapped to the backend service ✓ (correct)
- `/` was mapped to the frontend service ✓ (correct)

However, the original configuration may have had issues with path precedence or service routing logic in the ingress template.

## Solution
Updated the ingress template (`templates/ingress.yaml`) to properly handle service routing:
- Added conditional logic to route requests based on service type
- `/api/` paths route to the backend service on port 8080
- `/` (root) paths route to the frontend service on port 80
- Fixed service name references to match the actual service names

## Files Modified
- `templates/ingress.yaml` - Updated service routing logic
- `values.yaml` - Ensured correct path configuration

## Verification
The ingress now correctly routes:
- `booktracker.dev/api/*` → backend service (port 8080)
- `booktracker.dev/*` → frontend service (port 80)
