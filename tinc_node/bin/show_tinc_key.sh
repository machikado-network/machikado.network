#!/bin/sh

tinc_netname="mchkd"
tinc_conf=/etc/tinc/"${tinc_netname}"/tinc.conf
node_name="$(grep -e '^Name' < "${tinc_conf}" |
  tr -d ' ' |
  cut -d '=' -f 2)"
cat /etc/tinc/"${tinc_netname}"/hosts/"${node_name}" |
  awk '/-----BEGIN RSA PUBLIC KEY-----/,/-----END RSA PUBLIC KEY-----/' |
  grep -v -e '-----BEGIN RSA PUBLIC KEY-----' -e '-----END RSA PUBLIC KEY-----' |
  tr -d '\n' | grep .
