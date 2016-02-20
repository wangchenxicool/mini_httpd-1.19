#!/bin/sh

program="/bin/net_manager.bin -d"
logfile="/etc/net_manager_restart.log"
sidfile="/etc/net_manager.sid"

#start dameo
$program
program_pid="$!";
demo_pid="$$";
echo "$demo_pid" > $sidfile
echo "$program_pid" >> $sidfile
echo "child pid is $program_pid"
echo "status is $?"

while [ 1 ]
do
    wait $program_pid
    exitstatus="$?"
    echo "child pid=$program_pid is gone, exitstatus is: $exitstatus " >> $logfile
    sleep 2
    $program
    program_pid="$!";
    echo "$demo_pid" > $sidfile
    echo "$program_pid" >> $sidfile
    echo "next child pid is $program_pid------- $(date)" >> $logfile
    echo "**************************" >> $logfile
    echo "next child pid is $program_pid"
    echo "next status is $?"
    echo "userkill is $userkill"
done
