# shellcheck shell=bash

function start_dbus() {
    log "Starting D-Bus daemon..."
    dbus-uuidgen --ensure
    dbus-daemon --system --nopidfile --nosyslog
}

function start_cron() {
    log "Starting cron service..."
    /etc/init.d/cron start > /dev/null 2>&1 || true
}

function start_asterisk() {
    log "Starting Asterisk service..."
    /etc/init.d/asterisk start > /dev/null 2>&1 || true
    sleep 5
}

function start_fail2ban() {
    log "Starting Fail2ban service..."
    /usr/bin/fail2ban-server -f > /dev/null 2>&1 || true
}
