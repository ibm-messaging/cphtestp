#!/bin/bash
export HOSTNAME=localhost
export BINDINGS=mqc
export QMNAME=PERF0

threads=${1:-200}


./cph -nt $threads -ms 204800 -vo 3 -rl 0 -id 1 -tc Responder -ss 0 -iq REQUEST -oq REPLY -db 1 -dx 10 -jp 1420 -jc SYSTEM.DEF.SVRCONN -jb $QMNAME -jt $BINDINGS -jh $HOSTNAME -wi 10 -wt 10 -to -1 -pp true -tx true 

