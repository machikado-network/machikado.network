#!/bin/sh

#
# まちかどネットワークtincノードセットアップスクリプト
#
# 使い方
#   ワンライナーでダウンロードして実行:
#     url="このスクリプトのURLをここに";(curl -L "${url}" || wget -O - "${url}") > /tmp/s; sudo sh /tmp/s <ノード名> <IPアドレス>
#   ローカルで実行:
#     chmod +x setup_node_with_sakura.sh
#     sudo ./setup_node_with_sakura.sh <tincノード名> <まちかどネットワーク側IPアドレス>
#

set -e

sakura_base_url="https://github.com/sizumita/machikado.network/releases/download/Sakura-v0.3.0/Sakura-v0.3.0"

unames="$(uname -s)"
if [ "${unames}" != "Linux" ]; then
  {
    echo "${unames} は未対応のOSです"
    echo "終了します"
  } >&2
  exit 1
fi

unamem="$(uname -m)"
case "${unamem}" in
  "aarch64" )
    target="aarch64-unknown-linux-gnu"
    ;;
  "armv7l" )
    target="armv7-unknown-linux-gnueabihf"
    ;;
  "x86_64" )
    target="x86_64-unknown-linux-gnu"
    ;;
  * )
    {
      echo "${unamem} は未対応のアーキテクチャです"
      echo "終了します"
    } >&2
    exit 1
    ;;
esac

url="${sakura_base_url}-${target}"
sakura_path="/usr/local/bin/sakura"
(curl -s -L "${url}" || wget -q -O - "${url}") > "${sakura_path}"
chmod +x "${sakura_path}"
# $@ でシェルスクリプトに渡された引数をすべてsakuraにわたす
sakura tinc setup $@
