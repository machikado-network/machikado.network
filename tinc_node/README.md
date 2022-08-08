# まちかどネットワークテスト環境

まちかどネットワーク関連のツールをテストするための仮想ネットワークを立ち上げる


## VMネットワークの構成

```
[fakeroot] ----(fake_inet)---- [gateway] ----(fake_lan)---- [client]
```

セグメント:
- fake_inet:
  - 172.16.38.0/24
  - インターネットのかわりのセグメント
- fake_lan:
  - 192.168.111.0/24
  - 自宅のLANのかわりのセグメント

ホスト(vm):
- fakeroot
  - fake_inet: 173.16.38.1
  - mchkd: 10.50.255.1
- gateway
  - fake_inet: 172.16.38.2
  - fake_lan: 192.168.111.2
  - mchkd: 10.50.255.2
  - NAT: fake_lan -> mchkd
- client
  - fake_lan: 192.168.111.3

`gateway` でNATが動作していて、clientに静的経路が設定されているので、`client` から `fakeroot` (10.50.255.1)に疎通する


## 起動

```sh
brew install virtualbox
brew install vagrant
vagrant plugin install vagrant-vyos
```

システム環境設定 > セキュリティとプライバシー から"Oracle America, inc"のシステムソフトウェアを「許可」する
参考: https://www.kotobato.jp/articles/tips/virtualbox-error-macos-security-privacy-sysprefs.html

```sh
vagrant up                      # VMのセットアップ
./exchange_key_in_vagrant.sh    # VM同士の公開鍵の交換

```

一気にやるならこんな感じ

```sh
vagrant destroy -f && vagrant up && ./exchange_key_in_vagrant.sh && say "オワッタヨ"
```


## 疎通確認

```
local:~$ vagrant ssh client
vagrant@client:~$ ping 10.50.255.1
```

この状態で、`gateway` を落としてみる。

```
local:~$ vagrant halt gateway
```

`10.50.255.1` へのpingが停止すれば`gateway`経由で`10.50.255.1`と通信できていることが確認できる。
