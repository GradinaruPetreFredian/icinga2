#!/bin/bash

# Description:  Custom script for checking websites with performance data included in the output of the check . 
# Author:       Petre Fredian Gradinaru, RO
# Date:         14 of January 2021

# Usage:   ./check_website.sh http://www.google.com
# Output:  OK - Connection to https://www.google.com took 0.452s RC: 200 OK | response_time=0.452s; exit 0;
# Obs:     Just a part of http codes were included. Feel free to add more if needed.

#Variables and defaults
STATE_OK=0;             # define the exit code if status is OK
STATE_WARNING=1;        # define the exit code if status is Warning
STATE_CRITICAL=2;       # define the exit code if status is Critical
STATE_UNKNOWN=3;        # define the exit code if status is Unknown

uri=$1;                 # define the url of the website to check
curloption="";          # define custom curl option for https websites

#Check if the website it's secure : 
string=$(echo $uri | cut -c1-5)
if [[ "$string" == "https" ]]; then
    curloption="-k"
fi

command="$(curl -s $curloption -o /dev/null -w 'Time: %{time_total} Code: %{response_code}\n' $uri -i)";
output=$command;

#Fetch response_time in seconds and response_code from the command output: 
response_time=$(echo $output | cut -f 2 -d " ")s;
response_code=$(echo $output | cut -f 4 -d " ");

case $response_code in
    200) echo "OK - Connection to ${uri} took ${response_time} RC: ${response_code} OK | response_time=${response_time}; exit $STATE_OK;";;
    301) echo "OK - Moved Permanently. Connection to ${uri} took ${response_time} RC: ${response_code} OK | response_time=${response_time}; exit $STATE_OK;";;
    302) echo "OK - Moved Permanently. Connection to ${uri} took ${response_time} RC: ${response_code} OK | response_time=${response_time}; exit $STATE_OK;";;
    401) echo "CRITICAL - Connection to ${uri} took ${response_time} RC: ${response_code} Unauthorized | response_time=${response_time}; exit $STATE_CRITICAL;";;
    403) echo "CRITICAL - Connection to ${uri} took ${response_time} RC: ${response_code} Forbidden | response_time=${response_time}; exit $STATE_CRITICAL;";;
    404) echo "CRITICAL - Connection to ${uri} took ${response_time} RC: ${response_code} Not Found | response_time=${response_time}; exit $STATE_CRITICAL;";;
    500) echo "CRITICAL - Connection to ${uri} took ${response_time} RC: ${response_code} Internal Server Error | response_time=${response_time}; exit $STATE_CRITICAL;";;
    *)   echo "CRITICAL - Connection to ${uri} took ${response_time} RC: ${response_code} Error | response_time=${response_time}; exit $STATE_CRITICAL;";;
esac
