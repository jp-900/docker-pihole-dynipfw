#!/bin/bash

set -ef

# cgi is executed by user www-data; need sudo to modify iptables.
shopt -s expand_aliases
alias iptables='sudo iptables'

# Use $HTTP_X_FORWARDED_FOR when running behind a reverse proxy.
# $REMOTE_ADDR would be used otherwise.
NEWIP=$HTTP_X_FORWARDED_FOR

# which iptable should be modified
TABLE=INPUT

# Find rule for the previous IP. What the 5 piped commands do:
#   1) List rules (-L) from table $TABLE with line numbers; do not use revers
#      DNS (-n)
#   2) Find all entries that allow access (RETURN from the table will end up in
#      ACCEPT) to DNS port (udp 53).
#   3) Find entries with a non-docker IP. (Assuming 172.x.x.x/16 to be docker)
#   4) Find the first (-m 1) entry which is not (-v) 127.0.0.1
#   5) Extract the rule number
RULENUMBER=$(iptables --line-numbers -nL $TABLE 2>/dev/null | grep -P "^[\d\s]+RETURN\s+udp  --  [\d\.\/\s]+ udp dpt:53$" | grep -Pv "172[\.\d]+/16" | grep -Pvm 1 "127.0.0.1" | grep -Po "^\d+")
iptables -D $TABLE $RULENUMBER
iptables -I $TABLE $RULENUMBER --proto udp --dport 53 -s $NEWIP -j RETURN

# Send HTTP response
if [[ $? -eq 0 ]] ; then
  echo "Status: 204 No content"
else
  echo "Status: 500 Internal Error"
fi
echo # End header
echo # Empty body
echo # End body

exit 0
