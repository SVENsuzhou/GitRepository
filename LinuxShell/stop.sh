#!/bin/bash
#author: zhu huifeng

. /etc/init.d/functions

my_stop()
{
local -a MyPid
local i=0
for I in 'GatewayServer -d' 'LogicServer -d' 'RecordServer -d' 'GlobalServer -d'; do
    for ID in `ps x | grep "$I" | grep -v grep | awk '{print $1}'`; do
        MyPid[$i]=$ID
        let i=$i+1
    done
    if [ ${#MyPid[*]} -eq 0 ]; then
        continue
    fi
    COMMAND() { kill -2 ${MyPid[@]}; }
    if [ "$I" = 'RecordServer -d' ]; then
        sleep 10
    else
        sleep 2
    fi
    action "stop ${I:0:${#I}-3} service:" COMMAND
    unset MyPid[@]
    let i=0
done
unset COMMAND
}

pid_test()
{
sleep 5
for I in 'GatewayServer -d' 'LogicServer -d' 'RecordServer -d' 'GlobalServer -d'; do
    ps x | grep -v grep | grep "$I" > /dev/null
    if [ $? -eq 0 ]; then
          echo -e "Warning: ${I:0:${#I}-3}\t进程没有结束，请手动终结该进程"
    fi
done
}

my_stop
pid_test
