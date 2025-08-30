#!/bin/bash
# test-services.sh

echo "Testing microservices..."

# Port forward to gateway service
kubectl port-forward -n microservices service/gateway-service 8080:8080 &
PF_PID=$!

# Wait for port forward to be ready
sleep 5

echo "Testing API endpoints..."

# Test users
echo "Testing Users API:"
curl -s http://localhost:8080/api/users | jq '.' || echo "Users API test failed"

# Test products
echo "Testing Products API:"
curl -s http://localhost:8080/api/products | jq '.' || echo "Products API test failed"

# Test creating an order
echo "Testing Order Creation:"
curl -s -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{"userId":1,"productId":1,"quantity":2}' | jq '.' || echo "Order creation test failed"

# Test notifications
echo "Testing Notifications API:"
curl -s http://localhost:8080/api/notifications | jq '.' || echo "Notifications API test failed"

# Clean up port forward
kill $PF_PID

echo "API testing completed!"