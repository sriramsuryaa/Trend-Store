#!/bin/bash

# Deploy and expose Grafana + Prometheus + nginx exporter for the Trend Store app.
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function get_loadbalancer_host() {
  local service="$1"
  local host
  host=$(kubectl get svc "$service" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
  if [ -z "$host" ]; then
    host=$(kubectl get svc "$service" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
  fi
  echo "$host"
}

echo "Deploying monitoring stack..."
kubectl apply -f "$DIR"

echo "Waiting for Prometheus and Grafana deployments..."
kubectl rollout status deployment/prometheus --timeout=180s
kubectl rollout status deployment/grafana --timeout=180s

echo "Monitoring stack deployed successfully."

PROMETHEUS_HOST=$(get_loadbalancer_host prometheus)
GRAFANA_HOST=$(get_loadbalancer_host grafana)

if [ -n "$PROMETHEUS_HOST" ]; then
  echo "Prometheus: http://$PROMETHEUS_HOST:9090"
else
  echo "Prometheus: service created, use kubectl get svc prometheus to find endpoint or port-forward if needed."
fi

if [ -n "$GRAFANA_HOST" ]; then
  echo "Grafana: http://$GRAFANA_HOST:3000"
  echo "Grafana credentials: admin/admin"
else
  echo "Grafana: service created, use kubectl get svc grafana to find endpoint or port-forward if needed."
fi

echo "Nginx exporter metrics are available at service nginx-metrics:9113 inside the cluster."
