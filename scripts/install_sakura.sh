#!/bin/sh
RELEASES_API="https://api.github.com/repos/machikado-network/sakura/releases/latest"
INSTALL_PATH="${1:-.}"

function install() {
  URL="$(echo "${1}" | grep "${2}")"
  echo "Download Sakura from ${URL}"
  rm -f "${INSTALL_PATH}/sakura"
  if hash curl 2>/dev/null; then
    curl -L -s "${URL}" > "${INSTALL_PATH}/sakura"
  else
    wget -q -r "${URL}" -o "${INSTALL_PATH}/sakura"
  fi
  chmod +x "${INSTALL_PATH}/sakura"
  exit 0
}

if hash jq 2>/dev/null; then
  RELEASES="$(curl -L -s "${RELEASES_API}" || wget -O - "${RELEASES_API}")}"
  ARCH="$(uname -m)"
  OS="$(uname -s)"
  URLS="$(echo "${RELEASES}" | jq -r '.assets[].browser_download_url' 2>/dev/null)"

  case "${OS}-${ARCH}" in
    "Linux-arm64" ) install "${URLS}" aarch64-unknown-linux-gnu ;;
    "Linux-X86_64" ) install "${URLS}" x86_64-unknown-linux-gnu ;;
    "Linux-armv7l" ) install "${URLS}" armv7-unknown-linux-gnueabihf ;;
  esac

  echo "No Matched Architecture and OS."
else
    echo "Please Install jq and retry."
fi

exit 1
