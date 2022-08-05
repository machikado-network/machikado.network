# tincテスト環境

## 動かしかた

```sh
brew install virtualbox
brew install vagrant
```

システム環境設定 > セキュリティとプライバシー から"Oracle America, inc"のシステムソフトウェアを「許可」する
参考: https://www.kotobato.jp/articles/tips/virtualbox-error-macos-security-privacy-sysprefs.html

```sh
vagrant up                      # VMのセットアップ
./exchange_key_in_vagrant.sh    # VM同士の公開鍵の交換

```
