#!/bin/sh
EXEC="/usr/bin/sss"
CONF="/usr/bin/config.json"
# reuse existing config when the container restarts
run() {
  if [ -f ${CONF} ]; then
    echo "Found existing config..."
  else
    if [ -z ${PSK} ]; then
      PSK=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32)
      echo "Using PSK: ${PSK}"
    else
      tee -a ${CONF} << EOF
{
    "server":"0.0.0.0",
    "server_port":${PORT},
    "password":"${PSK}",
    "method":"${$METHOD}",
    "timeout":300,
    "fast_open":true,
    "plugin":"obfs",
    "plugin-opts":"obfs=${OBFS}"
}
EOF
    fi
      ${EXEC} -c ${CONF}
  fi
}
if [ -z "$@" ]; then
  run
else
  exec "$@"
fi