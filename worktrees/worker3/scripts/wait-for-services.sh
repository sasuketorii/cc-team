#!/bin/bash

# サービスの起動を待つスクリプト

set -e

echo "Waiting for services to be ready..."

# PostgreSQLの起動待ち
until docker-compose exec -T postgres pg_isready -U ccteam -d ccteam_test; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done
echo "PostgreSQL is ready!"

# Redisの起動待ち
until docker-compose exec -T redis redis-cli ping | grep -q PONG; do
  echo "Waiting for Redis..."
  sleep 2
done
echo "Redis is ready!"

# アプリケーションの起動待ち
until curl -f http://localhost:3000/health > /dev/null 2>&1; do
  echo "Waiting for application..."
  sleep 2
done
echo "Application is ready!"

echo "All services are ready!"