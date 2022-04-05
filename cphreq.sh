#!/bin/bash
export BINDINGS=mqc

threads=${1:-1}
msgsize=${2:-2048}
host="${MQ_QMGR_HOSTNAME:-localhost}"
qmname="${MQ_QMGR_NAME:-PERF0}"
port="${MQ_QMGR_PORT:-1420}"
channel="${MQ_QMGR_CHANNEL:-SYSTEM.DEF.SVRCONN}"
requestq="${MQ_QMGR_QREQUEST_PREFIX:-REQUEST}"
replyq="${MQ_QMGR_QREPLY_PREFIX:-REPLY}"
extra="${MQ_CPH_EXTRA}"
userid="${MQ_USERID}"
password="${MQ_PASSWORD}"
nonpersistent="${MQ_NON_PERSISTENT:-0}"
runlength="${MQ_RUNLENGTH:-90}"
reconnect="${MQ_AUTORECONNECT:-MQCNO_RECONNECT_DISABLED}"


if [ "${nonpersistent}" -eq 1 ]; then
  persistent_flags="-tx false -pp false"
else
  persistent_flags="-tx true -pp true"
fi


if [ -n "${MQ_USERID}" ]; then
  ./cph -nt $threads -ms $msgsize -rl $runlength -id 1 -tc Requester -ss 10 -iq $requestq -oq $replyq -db 1 -dx 10 -jp $port -jc $channel -jb $qmname -jt $BINDINGS -jh $host -wi 10 -to 30 $persistent_flags -ar $reconnect -us $userid -pw $password $extra -jl ${MQ_TLS_CIPHER} -jw ${MQ_TLS_CERTLABEL}
else
  ./cph -nt $threads -ms $msgsize -rl $runlength -id 1 -tc Requester -ss 10 -iq $requestq -oq $replyq -db 1 -dx 10 -jp $port -jc $channel -jb $qmname -jt $BINDINGS -jh $host -wi 10 -to 30 $persistent_flags -ar $reconnect $extra -jl ${MQ_TLS_CIPHER} -jw ${MQ_TLS_CERTLABEL}
fi
