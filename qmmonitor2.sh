. setmqenv -s
#MQ Client only
#gcc -m64 -o qmmonitor2 qmmonitor2.c -I $MQ_INSTALLATION_PATH/inc -L $MQ_INSTALLATION_PATH/lib64 -Wl,-rpath=$MQ_INSTALLATION_PATH/lib64 -Wl,-rpath=/usr/lib64 -lmqic_r -lpthread

#MQ Server + Client
gcc -m64 -o qmmonitor2 qmmonitor2.c -I $MQ_INSTALLATION_PATH/inc -L $MQ_INSTALLATION_PATH/lib64 -Wl,-rpath=$MQ_INSTALLATION_PATH/lib64 -Wl,-rpath=/usr/lib64 -lmqm_r -lpthread
