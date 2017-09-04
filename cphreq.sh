#!/bin/bash

export HOSTNAME=localhost
export BINDINGS=mqc
export QMNAME=PERF0

threads=${1:-1}
msg_size=${2:-2048}

./cph -nt $threads -ms $msg_size -rl 180 -id 1 -tc Requester -ss 10 -iq REQUEST -oq REPLY -db 1 -dx 10 -jp 1420 -jc SYSTEM.DEF.SVRCONN -jb $QMNAME -jt $BINDINGS -jh $HOSTNAME -wi 10 -to 30 -pp true -tx true

