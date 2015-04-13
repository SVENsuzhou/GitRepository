#!/bin/bash
#author: zhu huifeng

. /etc/init.d/functions

my_stop()
{
for I in 'GatewayServer' 'LogicServer' 'RecordServer' 'GlobalServer'; do
    for ID in `ps x | grep $I | grep -v grep | awk '{print $1}'`; do
        COMMAND() { kill -2 $ID; }
        if [ $I = 'RecordServer' ]; then
            sleep 60
        else
            sleep 2
        fi
        action "stop $I service:" COMMAND
    done
done
unset COMMAND
}

pid_test()
{
sleep 5
for I in 'GatewayServer' 'LogicServer' 'RecordServer' 'GlobalServer'; do
    ps x | grep -v grep | grep $I > /dev/null
    if [ $? -eq 0 ]; then
          echo "Warning: $I 进程没有结束，请手动终结该进程"
    fi
done
}

my_stop
pid_test