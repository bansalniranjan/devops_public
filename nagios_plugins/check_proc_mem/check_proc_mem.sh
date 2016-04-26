#!/bin/bash -e
##-------------------------------------------------------------------
## @copyright 2016 DennyZhang.com
## Licensed under MIT
##   https://raw.githubusercontent.com/DennyZhang/devops_public/master/LICENSE
##
## File: check_proc_mem.sh
## Author : Denny <denny@dennyzhang.com>
## Description :
## --
##
## Link: http://www.dennyzhang.com/nagois_monitor_process_memory
##
## Created : <2014-10-25>
## Updated: Time-stamp: <2016-04-26 22:49:55>
##-------------------------------------------------------------------
if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && \
    [ "$3" = "-c" ] && [ "$4" -gt "0" ]; then
    pidPattern=${5?"specify how to get pid"}

    if [ "$pidPattern" = "--pidfile" ]; then
        pidfile=${6?"pidfile to get pid"}
        pid=$(cat "$pidfile")
    elif [ "$pidPattern" = "--cmdpattern" ]; then
        cmdpattern=${6?"command line pattern to find out pid"}
        pid=$(ps -ef | grep "$cmdpattern" | grep -v grep | grep -v check_proc_mem.sh | head -n 1 | awk -F' ' '{print $2}')
    elif [ "$pidPattern" = "--pid" ]; then
        pid=${6?"pid"}
    else
        echo "ERROR input for pidpattern"
        exit 2
    fi

    if [ -z "$pid" ]; then
        echo "ERROR: no related process is found"
        exit 2
    fi

    memVmSize=$(grep 'VmSize:' "/proc/${pid}/status" | awk -F' ' '{print $2}')
    memVmSize=$(($memVmSize/1024))

    memVmRSS=$(grep 'VmRSS:' "/proc/${pid}/status" | awk -F' ' '{print $2}')
    memVmRSS=$(($memVmRSS/1024))

    if [ "$memVmRSS" -ge "$4" ]; then
        echo "Memory: CRITICAL VIRT: $memVmSize MB - RES: $memVmRSS MB used!|RES=$(($memVmRSS*1024*1024));;;;"
        exit 2
    elif [ "$memVmRSS" -ge "$2" ]; then
        echo "Memory: WARNING VIRT: $memVmSize MB - RES: $memVmRSS MB used!|RES=$(($memVmRSS*1024*1024));;;;"
        exit 1
    else
        echo "Memory: OK VIRT: $memVmSize MB - RES: $memVmRSS MB used!|RES=$(($memVmRSS*1024*1024));;;;"
        exit 0
    fi

else
    echo "check_proc_mem v1.0"
    echo ""
    echo "Usage:"
    echo "check_proc_mem.sh -w <warn_MB> -c <criti_MB> <pid_pattern> <pattern_argument>"
    echo ""
    echo "Below: If tomcat use more than 1024MB resident memory, send warning"
    echo "check_proc_mem.sh -w 1024 -c 2048 --pidfile /var/run/tomcat7.pid"
    echo "check_proc_mem.sh -w 1024 -c 2048 --pid 11325"
    echo "check_proc_mem.sh -w 1024 -c 2048 --cmdpattern \"tomcat7.*java.*Dcom\""
    echo ""
    echo "Copyright (C) 2014 DennyZhang (denny@dennyzhang.com)"
    exit
fi
## File - check_proc_mem.sh ends
