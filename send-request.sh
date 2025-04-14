#!/bin/bash

# Set default endpoint if ENDPOINT is not provided
ENDPOINT=${ENDPOINT:-"http://0.0.0.0:8000"}
IDNORM_LICENSE_KEY=${IDNORM_LICENSE_KEY:-""}

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "Usage: $0 <document-image-path1, required> <document-image-path2, optional>"
  exit 1
fi

IMAGE_PATH="$1"
IMAGE_PATH2="$2"

if [ ! -f "$IMAGE_PATH" ]; then
  echo "Error: File '$IMAGE_PATH' not found!"
  exit 1
fi

# Create a single temporary file
TMP_FILE=$(mktemp)

if [ -f "$IMAGE_PATH2" ]; then
  img2Base64=$(base64 "$IMAGE_PATH2" | tr -d '\n')
else
  img2Base64=""
fi

# Write JSON payload with base64-encoded image
{
  echo -n '{"firstImage": "'
  base64 "$IMAGE_PATH" | tr -d '\n'
  echo -n '", "secondImage": "'
  echo -n "$img2Base64"
  echo -n '"}'
} > "$TMP_FILE"

# Send the request using curl
if [ -n "$IDNORM_LICENSE_KEY" ]; then
  curl -X POST "$ENDPOINT/api/v1/verify" \
       -H "Content-Type: application/json" \
       -H "idnorm-license-key: $IDNORM_LICENSE_KEY" \
       --data-binary @"$TMP_FILE"
else
  curl -X POST "$ENDPOINT/api/v1/verify" \
       -H "Content-Type: application/json" \
       --data-binary @"$TMP_FILE"
fi

# Clean up temporary file
rm -f "$TMP_FILE"
