# What is this

A layer on top of [Pihole in docker](https://github.com/pi-hole/docker-pi-hole/) which adds a firewall blocking all incoming traffic except from one (dynamic) IP address.
The idea is to prevent unauthorized access to a (otherwise) publicly available pihole server without the need of a VPN.

Only one IP - the server's owner's home IP - is granted access. Since private IP addresses usually change regularly, it needs to be updated. This is initiated by the home router that supports a dyndns feature.

