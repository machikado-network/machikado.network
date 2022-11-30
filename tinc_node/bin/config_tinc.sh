#!/bin/sh

#
# provisionのVM内で実行する
#
# 使い方
#   [ADDRESS=address] [PORT=port] /usr/local/bin/config_tinc.sh name key
#       name     リモートノード
#       key      リモートノードのRSA公開鍵
#       address  リモートノードのインターネット側ホスト名またはIPアドレス
#       port     リモートノードのポート

set -e

tinc_netname="mchkd"
tinc_conf=/etc/tinc/"${tinc_netname}"/tinc.conf
#remote_node_name="fakeroot"
#remote_node_address="192.168.56.254"
#remote_node_port="655"
#remote_node_key="MIIBCgKCAQEA1IQpdK84PjPdD5CtIv42pK0q/QCAgGq/Hu2THpuR6QxqtmgnEXOCAhJtNmSFmv3LbIxbtbs9GV6hStXh/F9IHEvinowoAlyeBm71/Ki3W1maebY/LSePRfS0SdFfNey+bWmnMEY2jEdLV6+rUcBqcR48e3q15Ps6Fbje670GtpdZWFlo/Oskpsu4B3gfNezt+akcXP/EAQq/tOpkUlnnnET9XVbyD5fUguNHt8KygUAIn+N6httBA7OQkDOTClxJ59gCeFAUOoN5P3ynUm2+MQE/zSM4D3IdvsQVC8ht0menQXyfLCTnWjdqr8UNgejLsd/auGu5+OgAt0bUU+lYQwIDAQAB"
remote_node_name="${1}"
remote_node_key="${2}"
remote_node_address="${ADDRESS}"
remote_node_port="${PORT}"


node_name="$(grep -e '^Name' < "${tinc_conf}" |
  tr -d ' ' |
  cut -d '=' -f 2)"

# リモートノードのhostファイルを作成する
{
  printf '# %s\n' "${remote_node_name}"
  if [ -n "${remote_node_address}" ] && [ -n "${remote_node_port}" ]; then
    printf 'Address = %s\n' "${remote_node_address}"
    printf 'Port = %s\n' "${remote_node_port}"
  fi
  printf '\n'

  printf -- '-----BEGIN RSA PUBLIC KEY-----\n'
  printf '%s\n' "${remote_node_key}" | fold -w 64
  printf -- '-----END RSA PUBLIC KEY-----\n'
} > /etc/tinc/"${tinc_netname}"/hosts/"${remote_node_name}"

# tinc.conf の更新
cat > "${tinc_conf}" <<EOF
Name = ${node_name}
Mode = switch
Device = /dev/net/tun
EOF
if [ -n "${remote_node_address}" ] && [ -n "${remote_node_port}" ]; then
  printf 'ConnectTo = %s\n' "${remote_node_name}" >> "${tinc_conf}"
fi

# tincサービスを再起動する
systemctl restart tinc@"${tinc_netname}".service
