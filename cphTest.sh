#!/bin/bash
echo "----------------------------------------"
echo "Initialising test environment-----------"
echo "----------------------------------------"
qmname="${MQ_QMGR_NAME:-PERF0}"
host="${MQ_QMGR_HOSTNAME:-localhost}"
port="${MQ_QMGR_PORT:-1420}"
echo "Testing QM: $qmname on host: $host using port: $port"
echo "Testing QM: $qmname on host: $host using port: $port" > /home/mqperf/cph/results
export MQSERVER="SYSTEM.ADMIN.SVRCONN/TCP/$host($port)";
cat /home/mqperf/cph/clearq.mqsc | /opt/mqm/bin/runmqsc -c $qmname > /home/mqperf/cph/output
echo "----------------------------------------"
echo "Starting cph tests----------------------"
echo "----------------------------------------"
./cphresp.sh >> /home/mqperf/cph/output &
#Wait for responders to start
sleep 30
echo "CPH Test Results" >> /home/mqperf/cph/results
echo "2K Persistent" >> /home/mqperf/cph/results
export threads=1
echo "$threads thread " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=8
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=16
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=32
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=64
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=128
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=200
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
echo "" >> /home/mqperf/cph/results
echo "20K Persistent" >> /home/mqperf/cph/results
export threads=1
echo "$threads thread " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=8
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=16
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=32
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=64
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=128
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=200
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
echo "" >> /home/mqperf/cph/results
echo "200K Persistent" >> /home/mqperf/cph/results
export threads=1
echo "$threads thread " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=8
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=16
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=32
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=64
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=128
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=200
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
cat /home/mqperf/cph/results
echo "----------------------------------------"
echo "cph testing finished--------------------"
echo "----------------------------------------"
