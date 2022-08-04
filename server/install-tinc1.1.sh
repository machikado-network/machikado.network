#!/bin/sh

#
# 使い方
#   sudo ./install-tinc1.1.sh
#

# エラーが出たらスクリプトを終了する
set -e

# Debian系かどうかをチェックする
if ! test -f /etc/debian_version; then
  echo "Debian系のOSではありません. 終了します" >&2
  exit 1
fi

# 作業用ディレクトリを作成
tmp=$(mktemp -d)

# 作業用ディレクトリに移動する
cd "${tmp}"

# 依存するパッケージのインストール
apt-get install -y build-essential libncurses5-dev libreadline-dev libz-dev libssl-dev liblzo2-dev

# tincを取得して展開する
curl -O https://www.tinc-vpn.org/packages/tinc-1.1pre18.tar.gz
tar -zxvf tinc-1.1pre18.tar.gz

# ビルドしてインストール
cd tinc-1.1pre18
./configure
make
make install

# ホームディレクトリに戻る
cd "${HOME}"

# 作業用ディレクトリを削除する
rm -rf "${tmp}"
