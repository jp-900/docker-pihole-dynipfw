# What is this

A minimalistic firewall added to
[Pihole in docker](https://github.com/pi-hole/docker-pi-hole/), blocking all
incoming traffic except from one (dynamic) IP address.
The idea is to prevent unauthorized access to a (otherwise) publicly available
pihole server without the need of a VPN.

This is useful if pihole is running on a remote server rather than in a local
network.
Only one IP - the server's owner's home IP - is granted access. Since private IP addresses usually change regularly, it needs to be updated. This is initiated by
the home router that supports a dyndns feature.


## Build & Run

Simple docker build & run:

    docker build \
      --build-arg DYNDNS_USER=... \
      --build-arg DYNDNS_PASSWORD=... \
      -t pihole:dynipfw .

    docker run -d \
      --name pihole \
      -p 53:53 \
      --env TZ=Europe/Berlin \
      --env WEBPASSWORD=... \
      --cap_add NET_ADMIN \
      pihole:dynipfw

Refer to `.env.list` for details about variables.


### docker compose

Copy `.env.list` to `.env` and modify it as needed. Then run

    docker compose up -d
