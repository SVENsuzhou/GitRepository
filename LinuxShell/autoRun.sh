#!/bin/bash
#Author: zhu huifeng
. /etc/init.d/functions

trap "auto_hup" SIGHUP
my_start()
{
cd platform/

for I in "[0-9]?LoggerServer" "[0-9]?LoginServer" "[0-9]?BillServer" "[0-9]?LicenseServer"; do
    SERVICE=`ps x | grep -v grep | egrep -o $I`
    CMD=`ls ~/platform/ | grep -v grep | egrep -o $I | sed -n '1p'`
    if [ -z $SERVICE ]; then
        COMMAND() { ./${SERVICE:-$CMD} -d > /dev/null; }
        action "start $CMD service:"  COMMAND
        echo `date`,"$CMD service started" >> ~/.cron.log
    fi
done
unset COMMAND
echo "=========================================================================" >> ~/.cron.log
}

auto_test()
{
    while true; do
        for I in "LoggerServer" "LoginServer" "BillServer" "LicenseServer"; do
            ps x | grep -v grep | grep $I > /dev/null
            if [ $? -ne 0 ]; then
                my_start > /dev/null
            fi
        done
        sleep 300 &
        wait
    done
}

auto_hup()
{
    for I in `ps x | grep 'Server' | grep -v 'Logger' | grep -v 'grep' | awk '{print $1}'`;do
        kill -HUP $I
    done
}



if [ $# -eq 0 ]; then
   my_start
elif [ $# -ne 0 ] && [ $1 = '-t' ]; then
   auto_test
fi