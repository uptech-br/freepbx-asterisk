# shellcheck shell=bash

function add_extra_ips() {
    local ipvlan_if="$(ipvlan_iface)"

    if [[ -z "${ipvlan_if}" ]]; then
        log "No interface found for ipvlan network (prefix: ${subnet_prefix})..."
        return 0
    fi

    if [[ -n "${EXTRA_IPV4:-}" ]]; then
        log "Adding extra IPv4 address '${EXTRA_IPV4}' to interface '${ipvlan_if}'."

        ip -4 addr flush dev "$ipvlan_if"
        ip -4 addr add "${EXTRA_IPV4}" dev "$ipvlan_if" || true

        if [[ -n "${IPV4_GATEWAY:-}" ]]; then
            ip -4 route replace default via "${IPV4_GATEWAY}" dev "$ipvlan_if" || true
        fi
    fi

    if [[ -n "${EXTRA_IPV6:-}" ]]; then
        log "Adding extra IPv6 address '${EXTRA_IPV6}' to interface '${ipvlan_if}'."

        ip -6 addr add "${EXTRA_IPV6}" dev "$ipvlan_if" || true

        if [[ -n "${IPV6_GATEWAY:-}" ]]; then
            ip -6 route replace default via "${IPV6_GATEWAY}" dev "$ipvlan_if" onlink || true
        fi
    fi
}
