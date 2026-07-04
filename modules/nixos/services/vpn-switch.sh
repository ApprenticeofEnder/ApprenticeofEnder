# shellcheck shell=bash
usage() {
  cat <<EOF
Usage: vpn-switch <command>

Commands:
  <name>   Stop active OpenVPN connections and connect to <name>
  off      Stop all active OpenVPN connections
  status   Show OpenVPN service status
  list     List configured VPN names

Run without arguments to show this help and current status.
EOF
}

run_systemctl() {
  if [[ ${EUID} -eq 0 ]]; then
    systemctl "$@"
  else
    sudo systemctl "$@"
  fi
}

stop_active_openvpn() {
  local -a active=()
  mapfile -t active < <(
    systemctl list-units --type=service --state=active,activating 'openvpn-*.service' --no-legend --plain |
      awk '{print $1}'
  )

  for unit in "${active[@]}"; do
    run_systemctl stop "${unit}"
  done
}

show_status() {
  systemctl list-units --type=service 'openvpn-*.service' --all --no-legend
}

list_vpns() {
  printf '%s\n' "${VPN_NAMES[@]}"
}

validate_name() {
  local target="$1"
  local name

  for name in "${VPN_NAMES[@]}"; do
    if [[ "${name}" == "${target}" ]]; then
      return 0
    fi
  done

  echo "Unknown VPN: ${target}" >&2
  echo "Run 'vpn-switch list' to see configured VPNs." >&2
  return 1
}

connect_to() {
  local target="$1"
  validate_name "${target}"
  stop_active_openvpn
  run_systemctl start "openvpn-${target}.service"
  echo "Connected to ${target}"
}

main() {
  if [[ $# -eq 0 ]]; then
    usage
    echo
    show_status
    return 0
  fi

  case "$1" in
  off)
    stop_active_openvpn
    echo "All OpenVPN connections stopped."
    ;;
  status)
    show_status
    ;;
  list)
    list_vpns
    ;;
  -h | --help | help)
    usage
    ;;
  *)
    connect_to "$1"
    ;;
  esac
}

main "$@"
