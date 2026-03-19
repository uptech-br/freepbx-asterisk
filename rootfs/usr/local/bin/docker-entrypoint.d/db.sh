wait_for_db() {
    log "Waiting for db to become available (timeout: 60 seconds)..."

    if ! timeout 60 bash -c 'until mysql -h "${DBHOST-db}" -u root -p"${DBROOT_PASSWORD-root}" -e "SELECT 1" > /dev/null 2>&1; do sleep 2; done'; then
        log "Error: db is not available after 60 seconds timeout."
        exit 1
    fi

    log "db is now online..."
}
