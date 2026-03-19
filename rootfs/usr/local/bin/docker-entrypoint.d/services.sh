# shellcheck shell=bash

start_dbus() {
    log "Starting D-Bus daemon..."
    dbus-uuidgen --ensure
    dbus-daemon --system --nopidfile --nosyslog
}

start_cron() {
    log "Starting cron service..."
    /etc/init.d/cron start > /dev/null 2>&1 || true
}

start_asterisk() {
    log "Starting Asterisk service..."
    /etc/init.d/asterisk start > /dev/null 2>&1 || true
    sleep 5
}

start_fail2ban() {
    log "Starting Fail2ban service..."
    /etc/init.d/fail2ban start > /dev/null 2>&1 || true
}
