#!/bin/bash
#Automated testing for centralized logging

echo
echo "Sending 100 test messages with 5 second intervals"
echo "Ctrl-c to stop"
echo

for i in {1..100}
do
   logger -s "Test message $i"
   sleep 5
done
echo "Testing complete!"
