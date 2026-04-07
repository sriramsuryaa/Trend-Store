#!/bin/bash

# Minimal Health Check Monitoring
# Just checks if the application is healthy

set -e

echo "Checking Trend Store Health..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Get Trend Store service URL
SERVICE_URL=$(kubectl get svc trend-store -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)

if [ -z "$SERVICE_URL" ]; then
    echo -e "${RED}ERROR: Cannot get Trend Store service URL${NC}"
    echo "Run: kubectl get svc trend-store"
    exit 1
fi

echo "Service URL: http://$SERVICE_URL"

# Check health endpoint
echo "Checking health endpoint..."
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$SERVICE_URL/health 2>/dev/null || echo "000")

if [ "$HEALTH_STATUS" = "200" ]; then
    echo -e "${GREEN}SUCCESS: Application is healthy!${NC}"
else
    echo -e "${RED}ERROR: Application health check failed (HTTP $HEALTH_STATUS)${NC}"
    exit 1
fi

# Check pod status
echo "Checking pod status..."
POD_COUNT=$(kubectl get pods -l app=trend-store --no-headers 2>/dev/null | wc -l)
RUNNING_PODS=$(kubectl get pods -l app=trend-store -o jsonpath='{.items[*].status.phase}' 2>/dev/null | grep -c "Running" || echo "0")

if [ "$POD_COUNT" -eq "$RUNNING_PODS" ] && [ "$POD_COUNT" -gt 0 ]; then
    echo -e "${GREEN}SUCCESS: All $POD_COUNT pods are running${NC}"
else
    echo -e "${RED}ERROR: $RUNNING_PODS/$POD_COUNT pods are running${NC}"
    kubectl get pods -l app=trend-store
    exit 1
fi

echo ""
echo -e "${GREEN}SUCCESS: Trend Store is running healthy!${NC}"
echo "Access your app: http://$SERVICE_URL"