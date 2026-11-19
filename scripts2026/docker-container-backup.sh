
#!/bin/bash

# ==========================================
# Docker Container Backup Script
# ==========================================

set -Eeuo pipefail

# Configuration
BACKUP_DIR="/opt/docker-backups"
REGISTRY="192.168.93.149:5000"
IMAGE_NAMESPACE="container-backups"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

ARCHIVE="$BACKUP_DIR/containers_${TIMESTAMP}.tar"
TEMP_DIR=$(mktemp -d)

SUCCESS_COUNT=0
FAILED_COUNT=0

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Cleanup temporary directory
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "========================================"
echo " Docker Container Backup"
echo " Date: $(date)"
echo "========================================"

# Get all running containers
mapfile -t CONTAINERS < <(docker ps -q)

if [ "${#CONTAINERS[@]}" -eq 0 ]; then
    echo "[INFO] No running containers found."
    exit 0
fi

echo "[INFO] Found ${#CONTAINERS[@]} running containers."

# Process each container
for CONTAINER_ID in "${CONTAINERS[@]}"; do

    CONTAINER_NAME=$(docker inspect \
        --format '{{.Name}}' "$CONTAINER_ID" | sed 's|^/||')

    SAFE_NAME=$(echo "$CONTAINER_NAME" |
        tr '[:upper:]' '[:lower:]' |
        sed 's/[^a-z0-9_.-]/-/g')

    echo
    echo "Processing: $CONTAINER_NAME"

    # 1. Export container filesystem
    if docker export \
        -o "$TEMP_DIR/${SAFE_NAME}.tar" "$CONTAINER_ID"; then

        echo "[SUCCESS] Container filesystem exported."

    else
        echo "[ERROR] Export failed: $CONTAINER_NAME"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        continue
    fi

    # 2. Create Docker image
    IMAGE_TAG="${REGISTRY}/${IMAGE_NAMESPACE}/${SAFE_NAME}:${TIMESTAMP}"

    if docker commit "$CONTAINER_ID" "$IMAGE_TAG"; then

        echo "[SUCCESS] Docker image created: $IMAGE_TAG"

    else
        echo "[ERROR] Image creation failed: $CONTAINER_NAME"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        continue
    fi

    # 3. Push image to registry
    if docker push "$IMAGE_TAG"; then

        echo "[SUCCESS] Image pushed to registry."
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))

    else
        echo "[ERROR] Image push failed: $IMAGE_TAG"
        FAILED_COUNT=$((FAILED_COUNT + 1))
    fi

done

# 4. Create one TAR archive containing all exports
if compgen -G "$TEMP_DIR/*.tar" > /dev/null; then

    tar -cf "$ARCHIVE" -C "$TEMP_DIR" .

    echo "[SUCCESS] TAR backup created: $ARCHIVE"

else
    echo "[WARNING] No container TAR files available."
fi

# 5. Delete backups older than 1 day
find "$BACKUP_DIR" -maxdepth 1 -type f \
    -name 'containers_*.tar' \
    -mmin +1440 \
    -print -delete
# Final report
echo
echo "========================================"
echo " Backup Summary"
echo "========================================"
echo "Total Containers : ${#CONTAINERS[@]}"
echo "Successful       : $SUCCESS_COUNT"
echo "Failed           : $FAILED_COUNT"
echo "TAR Archive      : $ARCHIVE"
echo "Retention        : Last 24 TAR files"
echo "========================================"

if [ "$FAILED_COUNT" -gt 0 ]; then
    exit 1
fi

