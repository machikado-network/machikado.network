#!/bin/sh

set -e

fakeroot_key="$(vagrant ssh fakeroot -c '/usr/local/sbin/show_tinc_key.sh' 2>/dev/null)"
gateway_key="$(vagrant ssh gateway -c '/usr/local/sbin/show_tinc_key.sh' 2>/dev/null)"

vagrant ssh fakeroot -c "sudo /usr/local/sbin/config_tinc.sh gateway ${gateway_key}" 2>/dev/null
vagrant ssh gateway -c "sudo ADDRESS=192.168.56.254 PORT=655 /usr/local/sbin/config_tinc.sh fakeroot ${fakeroot_key}" 2>/dev/null
