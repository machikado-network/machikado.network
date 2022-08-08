#!/bin/sh

set -e

## sakuraを使わずにダミースクリプトでtincのセットアップをおこなう場合
#docker exec -it tinc_node-fakeroot-1 ./setup_gateway.sh fakeroot 10.50.255.1
#docker exec -it tinc_node-gateway-1 ./setup_gateway.sh gateway 10.50.255.2
# sakuraでtincのセットアップをおこなう場合
docker exec -it tinc_node-fakeroot-1 ./setup_node_with_sakura.sh fakeroot 10.50.255.1
docker exec -it tinc_node-gateway-1 ./setup_node_with_sakura.sh gateway 10.50.255.2

fakeroot_key="$(docker exec tinc_node-fakeroot-1 './bin/show_tinc_key.sh')"
gateway_key="$(docker exec tinc_node-gateway-1 './bin/show_tinc_key.sh')"

docker exec tinc_node-fakeroot-1 ./bin/config_tinc.sh gateway "${gateway_key}"
docker exec -e "ADDRESS=fakeroot" -e "PORT=655" tinc_node-gateway-1 ./bin/config_tinc.sh fakeroot "${fakeroot_key}"
