# shellcheck shell=bash

function ipvlan_iface() {
    ip -o link show type ipvlan | awk -F': ' '{print $2}' | cut -d'@' -f1 | head -n1
}

function add_extra_ips() {
    local iface="$(ipvlan_iface)"

    if [[ -z "${iface}" ]]; then
        log "No interface found for ipvlan network (prefix: ${subnet_prefix})..."
        return 0
    fi

    if [[ -n "${EXTRA_IPV4:-}" ]]; then
        log "Adding extra IPv4 address '${EXTRA_IPV4}' to interface '${iface}'."

        ip -4 addr flush dev "$iface"
        ip -4 addr add "${EXTRA_IPV4}" dev "$iface" || true

        if [[ -n "${IPV4_GATEWAY:-}" ]]; then
            ip -4 route replace default via "${IPV4_GATEWAY}" dev "$iface" || true
        fi
    fi

    if [[ -n "${EXTRA_IPV6:-}" ]]; then
        log "Adding extra IPv6 address '${EXTRA_IPV6}' to interface '${iface}'."

        ip -6 addr add "${EXTRA_IPV6}" dev "$iface" || true

        if [[ -n "${IPV6_GATEWAY:-}" ]]; then
            ip -6 route replace default via "${IPV6_GATEWAY}" dev "$iface" onlink || true
        fi
    fi
}
