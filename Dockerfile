FROM ubuntu:16.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        gnupg \
        wget \
        hostapd \
        iptables \
        isc-dhcp-server \
        ntp \
        man && \
    rm -rf /var/lib/apt/lists/*

COPY dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
RUN echo "" > /var/lib/dhcp/dhcpd.leases

COPY hostapd/hostapd.conf /etc/hostapd.conf

RUN echo "broadcast 172.16.10.255" >> /etc/ntp.conf

ADD entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

ENTRYPOINT [ "/bin/entrypoint.sh" ]
