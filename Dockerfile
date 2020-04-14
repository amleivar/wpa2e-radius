FROM ubuntu:16.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        gnupg \
        wget \
        hostapd \
        iptables \
        isc-dhcp-server \
        ntp \
	freeradius \
        man && \
    rm -rf /var/lib/apt/lists/*

COPY dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
RUN echo "" > /var/lib/dhcp/dhcpd.leases

COPY hostapd/hostapd.conf /etc/hostapd.conf

RUN echo "broadcast 172.16.10.255" >> /etc/ntp.conf

COPY freeradius/radiusd.conf /etc/freeradius/radiusd.conf
COPY freeradius/clients.conf /etc/freeradius/clients.conf
COPY freeradius/users /etc/freeradius/users
COPY freeradius/eap.conf /etc/freeradius/eap.conf
COPY freeradius/site-eap /etc/freeradius/sites-available/site-eap
RUN cd /etc/freeradius/sites-enabled && rm -rf * && ln -s ../sites-available/site-eap site-eap
RUN mkdir -p /tmp/radiusd && chown freerad:freerad /tmp/radiusd/
RUN rm -rf /etc/freeradius/certs/*
COPY EasyRSA-3.0.1/pki/dh.pem /etc/freeradius/certs/dh
COPY EasyRSA-3.0.1/pki/private/server.key /etc/freeradius/certs/server.key
COPY EasyRSA-3.0.1/pki/issued/server.crt /etc/freeradius/certs/server.pem
COPY EasyRSA-3.0.1/pki/ca.crt /etc/freeradius/certs/ca.pem
RUN chown freerad:freerad /etc/freeradius/certs/*

ADD entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

ENTRYPOINT [ "/bin/entrypoint.sh" ]
