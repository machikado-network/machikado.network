curl -O https://www.tinc-vpn.org/packages/tinc-1.1pre18.tar.gz

tar -zxvf tinc-1.1pre18.tar.gz

sudo apt-get install build-essential libncurses5-dev libreadline-dev libz-dev libssl-dev liblzo2-dev -y

cd tinc-1.1pre18 && ./configure && make && make install
