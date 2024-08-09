# Firewalled pihole with dynamic IP access

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

#### Simple docker build & run:

    docker build \
      --build-arg DYNDNS_USER=... \
      --build-arg DYNDNS_PASSWORD=... \
      -t pihole:dynipfw .

    docker run -d \
      --name pihole \
      -p 53:53/udp \
      --env TZ=Europe/Berlin \
      --env WEBPASSWORD=... \
      --cap_add NET_ADMIN \
      pihole:dynipfw

Refer to `.env.list` for details about variables.


#### docker compose

Copy `.env.list` to `.env` and modify it as needed. Then run

    docker compose up -d

## How it works

Access to port 53 (DNS) is blocked by `iptables`. The allowed IP address is
updated by `dyndns.cgi` which is executed when a DynDNS HTTP request is received
by the integrated webserver.

Most consumer routers have built-in support for DynDNS services. We use this to
tell pihole that out home IP has changed.

### Router config

Assuming that pihole's integrated web interface is available at
`https://pihole.example.com`:
* Update URL: `https://pihole.example.com/cgi-bin/dyndns.cgi`
* Domain name: *does not matter (unused)*
* Username: *your chosen value for DYNDNS_USER*
* Password: *your chosen value for _DYNDNS_PASSWORD*

_Note:_ Even though the IP update works, your router may report issues because
it tries to verify the updated DNS record (which we don't actually update).

In order to have you local network devices use pihole as DNS, your router should
have the pihole server configured as DNS server. Note that *primary DNS* and
*secondary DNS* do not necessarily imply a priority, but may be used by random
choice. You might want to set both to the same value.

To test if you can access your DNS server: `dig @pihole.example.com github.com`

### Allow local access on the pihole host

You might want to allow other containers on the same host (or the host itself)
to use pihole. To do so, simply whitelist docker networks. Example for the
default bridge network:

    docker exec <pihole-container-name> \
      iptables -I INPUT 1 -s 172.17.0.0/16 -p udp --dport 53 -j RETURN

You can repeat this to add other networks; simply change the network within the
command.

**Important:** Whitelisting anything but a `172.x.0.0/16` network will break
functionality, see `dyndns.cgi`.
