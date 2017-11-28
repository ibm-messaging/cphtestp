#!/bin/bash
export BINDINGS=mqc

threads="${1:-200}"
host="${MQ_QMGR_HOSTNAME:-localhost}"
qmname="${MQ_QMGR_NAME:-PERF0}"
port="${MQ_QMGR_PORT:-1420}"
channel="${MQ_QMGR_CHANNEL:-SYSTEM.DEF.SVRCONN}"
requestq="${MQ_QMGR_QREQUEST_PREFIX:-REQUEST}"
replyq="${MQ_QMGR_QREPLY_PREFIX:-REPLY}"



./cph -nt $threads -ms 204800 -vo 3 -rl 0 -id 1 -tc Responder -ss 0 -iq $requestq -oq $replyq -db 1 -dx 10 -jp $port -jc $channel -jb $qmname -jt $BINDINGS -jh $host -wi 10 -wt 10 -to -1 -pp true -tx true 
