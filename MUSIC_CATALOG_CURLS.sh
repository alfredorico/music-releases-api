#!/bin/bash

BASE_URL="http://localhost:3000/api/releases"
CONTENT_TYPE="Content-Type: application/json"

echo "=========================================="
echo "Caso 1: Crear solo un Artist"
echo "=========================================="
curl -s -X POST "$BASE_URL" \
  -H "$CONTENT_TYPE" \
  -d '{"artist": {"name": "Radiohead"}}' | jq .

echo ""
echo "=========================================="
echo "Caso 2: Crear solo un Release"
echo "=========================================="
curl -s -X POST "$BASE_URL" \
  -H "$CONTENT_TYPE" \
  -d '{"release": {"name": "OK Computer", "released_at": "1997-05-21T00:00:00Z"}}' | jq .

echo ""
echo "=========================================="
echo "Caso 3: Crear Artist y Release juntos"
echo "=========================================="
curl -s -X POST "$BASE_URL" \
  -H "$CONTENT_TYPE" \
  -d '{"artist": {"name": "Pink Floyd"}, "release": {"name": "The Dark Side of the Moon", "released_at": "1973-03-01T00:00:00Z"}}' | jq .

echo ""
echo "=========================================="
echo "Caso 4: Crear todo (Artist, Release, Album)"
echo "=========================================="
curl -s -X POST "$BASE_URL" \
  -H "$CONTENT_TYPE" \
  -d '{"artist": {"name": "Nirvana"}, "release": {"name": "Nevermind", "released_at": "1991-09-24T00:00:00Z"}, "album": {"name": "Nevermind", "duration_in_minutes": 49}}' | jq .

echo ""
echo "=========================================="
echo "Caso 5: Crear Album con IDs existentes"
echo "=========================================="
curl -s -X POST "$BASE_URL" \
  -H "$CONTENT_TYPE" \
  -d '{"artist_id": 1, "release_id": 1, "album": {"name": "OK Computer", "duration_in_minutes": 53}}' | jq .

echo ""
echo "=========================================="
echo "Error: Sin recursos"
echo "=========================================="
curl -s -X POST "$BASE_URL" \
  -H "$CONTENT_TYPE" \
  -d '{}' | jq .

echo ""
echo "=========================================="
echo "Error: Album sin Artist"
echo "=========================================="
curl -s -X POST "$BASE_URL" \
  -H "$CONTENT_TYPE" \
  -d '{"release": {"name": "Test Release", "released_at": "2020-01-01T00:00:00Z"}, "album": {"name": "Test Album", "duration_in_minutes": 45}}' | jq .