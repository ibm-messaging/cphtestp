#!/bin/bash
echo "----------------------------------------"
echo "Initialising test environment-----------"
echo "----------------------------------------"
export MQSERVER="SYSTEM.ADMIN.SVRCONN/TCP/localhost(1420)";
cat /home/mqperf/cph/clearq.mqsc | /opt/mqm/bin/runmqsc -c > /home/mqperf/cph/output
echo "----------------------------------------"
echo "Starting cph tests----------------------"
echo "----------------------------------------"
./cphresp.sh >> /home/mqperf/cph/output &
#Wait for responders to start
sleep 30
echo "CPH Test Results" > /home/mqperf/cph/results
echo "2K Persistent" >> /home/mqperf/cph/results
export threads=1
echo "$threads thread " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=8
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
