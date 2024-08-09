FROM pihole/pihole:latest

ARG DYNDNS_USER
ARG DYNDNS_PASSWORD

RUN apt-get update \
   && apt-get install -y iptables

COPY dyndns.cgi /usr/lib/cgi-bin/dyndns.cgi

RUN chmod 500 /usr/lib/cgi-bin/dyndns.cgi \
   && chown www-data:www-data /usr/lib/cgi-bin/dyndns.cgi \
   && echo "www-data ALL=NOPASSWD: /usr/sbin/iptables" > /etc/sudoers.d/iptables \
   && ln -s /etc/lighttpd/conf-available/10-cgi.conf /etc/lighttpd/conf-enabled/10-cgi.conf \
   && ln -s /etc/lighttpd/conf-available/05-auth.conf /etc/lighttpd/conf-enabled/05-auth.conf \
   && echo ${DYNDNS_USER:?Value is required for dyndns client authentication}:${DYNDNS_PASSWORD:?Value is required for dyndns client authentication} > /etc/lighttpd/pwd.txt \
   && cat >> /etc/lighttpd/conf-available/05-auth.conf <<EOT
server.modules += ("mod_authn_file")
auth.backend = "plain"
auth.backend.plain.userfile = "/etc/lighttpd/pwd.txt"

auth.require = ( "/cgi-bin/" =>
(
"method" => "basic",
"realm" => "Password protected area",
"require" => "valid-user"
)
)
EOT

RUN mkdir /etc/s6-overlay/s6-rc.d/iptables \
   && echo "oneshot" > /etc/s6-overlay/s6-rc.d/iptables/type \
   && echo "/iptables-init" > /etc/s6-overlay/s6-rc.d/iptables/up \
   && touch /etc/s6-overlay/s6-rc.d/user/contents.d/iptables \
   && chmod a+x /etc/s6-overlay/s6-rc.d/iptables/up \
   && touch /iptables-init \
   && chmod u+x /iptables-init \
   && cat > /iptables-init <<EOT
#!/bin/bash
# Allow requests from localhost
iptables -A INPUT -s 127.0.0.1 -p udp --dport 53 -j RETURN
# This is a placeholder that will be replaced by the user's home IP address
iptables -A INPUT -s 127.0.1.1 -p udp --dport 53 -j RETURN
# Block all others
iptables -A INPUT -p udp --dport 53 -j REJECT
EOT
