FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive

#RUN apt-get -y update && \
#    apt-get -y install systemd tinc && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*
RUN apt-get -y update && \
    apt-get -y install systemd tinc curl && \
    apt-get -y install sudo socat tcpdump traceroute vim && \
    apt-get clean

COPY . /workdir/

WORKDIR /workdir

RUN chmod +x setup_gateway.sh
RUN chmod +x setup_node_with_sakura.sh
RUN chmod +x bin/*

#COPY ./app/cm-update-7seg.service /etc/systemd/system/
#RUN systemctl enable cm-update-7seg.service

STOPSIGNAL SIGRTMIN+3
CMD [ "/sbin/init" ]

