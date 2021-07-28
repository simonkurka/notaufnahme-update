#!/bin/bash
set -euo pipefail

# Check if variables are empty
if [ -z "${PACKAGE}" ]; then echo "\$PACKAGE is empty."; exit 1; fi
if [ -z "${VERSION}" ]; then echo "\$VERSION is empty."; exit 1; fi
if [ -z "${DBUILD}" ]; then echo "\$DBUILD is empty."; exit 1; fi

# Directory this script is located in + /resources
DRESOURCES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/resources"

function sedvars() {
	sed -e "s|__AKTINUPDATEDIR__|/var/lib/aktin/update|g" \
	    -e "s|__PACKAGE__|${PACKAGE}|g" \
	    -e "s|__VERSION__|${VERSION}|g" \
	    "${1}" > "${2}"
}

function build_linux() {
	mkdir -p "${DBUILD}/usr/bin" "${DBUILD}/lib/systemd/system" "${DBUILD}/etc/apt/sources.list.d/" "${DBUILD}/usr/share/${PACKAGE}"
	sedvars "${DRESOURCES}/update" "${DBUILD}/usr/bin/${PACKAGE}"
	sedvars "${DRESOURCES}/update.service" "${DBUILD}/lib/systemd/system/${PACKAGE}.service"
	sedvars "${DRESOURCES}/update.socket" "${DBUILD}/lib/systemd/system/${PACKAGE}.socket"
	sedvars "${DRESOURCES}/info" "${DBUILD}/usr/bin/${PACKAGE}-info"
	sedvars "${DRESOURCES}/info.service" "${DBUILD}/lib/systemd/system/${PACKAGE}-info.service"
	sedvars "${DRESOURCES}/info.timer" "${DBUILD}/lib/systemd/system/${PACKAGE}-info.timer"
	chmod +x "${DBUILD}/usr/bin/${PACKAGE}" "${DBUILD}/usr/bin/${PACKAGE}-info"
}

