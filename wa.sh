#!/usr/bin/env bash
# WhatsApp Quick Chat – Send WhatsApp messages without saving contact
# Author: Sachin (SYCRONIX)
# GitHub: https://github.com/SYCRONIX/whatsapp-quick-chat

set -euo pipefail

# Colors (auto disable if not terminal)
if [[ -t 1 ]]; then
    R="\e[31m"; G="\e[32m"; Y="\e[33m"; B="\e[34m"; O="\e[35m"; C="\e[36m"; W="\e[37m"
else
    R=""; G=""; Y=""; B=""; O=""; C=""; W=""
fi

# Banner with fallback
banner() {
    if command -v toilet &>/dev/null; then
        toilet -f big -F gay "SYCRONIX"
    else
        echo -e "${C}========================================${W}"
        echo -e "${C}          SYCRONIX WA TOOL${W}"
        echo -e "${C}========================================${W}"
    fi
}

# Check dependencies
check_deps() {
    local missing=()
    command -v printf &>/dev/null || missing+=("printf")
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${R}Missing: ${missing[*]}. Install 'coreutils' or 'busybox'.${W}"
        exit 1
    fi
}

# Pure bash URL encode
url_encode() {
    local s="$1"
    local encoded=""
    for ((i=0; i<${#s}; i++)); do
        c="${s:i:1}"
        case "$c" in
            [a-zA-Z0-9.~_-]) encoded+="$c" ;;
            ' ') encoded+="%20" ;;
            *) printf -v h "%%%02X" "'$c"; encoded+="$h" ;;
        esac
    done
    echo "$encoded"
}

# Open URL cross-platform
open_url() {
    local url="$1"
    if command -v termux-open-url &>/dev/null; then
        termux-open-url "$url"
    elif command -v xdg-open &>/dev/null; then
        xdg-open "$url"
    elif command -v open &>/dev/null; then
        open "$url"
    else
        echo -e "${Y}Can't open browser. Copy this URL manually:${W} $url"
    fi
}

# Clean number (allow + and digits)
clean_number() {
    echo "$1" | sed 's/[^0-9+]//g'
}

# Send message
send_message() {
    local num=$(clean_number "$1")
    local msg_enc=$(url_encode "$2")
    local url="https://wa.me/${num}?text=${msg_enc}"
    echo -e "${G}Opening WhatsApp for +${num}...${W}"
    open_url "$url"
}

# About
about() {
    echo -e "${C}Author   : Sachin (SYCRONIX)${W}"
    echo -e "${C}Repo     : https://github.com/SYCRONIX/whatsapp-quick-chat${W}"
    echo -e "${C}License  : MIT${W}"
}

# Main menu loop
main_menu() {
    while true; do
        echo ""
        read -p "📞 Target number (with country code, e.g., 919876543210) : " num
        [[ -z "$num" ]] && { echo -e "${R}Number required!${W}"; continue; }
        echo "[1] Send Message"
        echo "[2] About"
        echo "[3] Exit"
        read -p "Choice: " ch
        case $ch in
            1) read -p "💬 Message: " msg
               [[ -z "$msg" ]] && echo -e "${R}Empty message!${W}" || send_message "$num" "$msg"
               ;;
            2) about ;;
            3) echo -e "${G}Bye! 👋${W}"; exit 0 ;;
            *) echo -e "${R}Invalid option${W}" ;;
        esac
    done
}

# Run
clear
check_deps
banner
echo -e "${C}============================================================${W}"
echo -e "${C}               WhatsApp Quick Chat v2.0${W}"
echo -e "${C}                Author : Sachin${W}"
echo -e "${C}============================================================${W}"
main_menu
