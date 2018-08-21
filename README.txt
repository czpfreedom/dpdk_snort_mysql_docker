########################
HOW TO RUN THE CONTAINER
########################
docker run -it --privileged -v /sys/bus/pci/devices:/sys/bus/pci/devices -v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages -v /sys/devices/system/node:/sys/devices/system/node -v /dev:/dev --name NAME -e NAME=NAME -e IMAGE=IMAGE IMAGE


#######################
HOW TO USE THE COUNTAINER
#######################
 you should modprobe igb_uio and configure the pci and hugepages on the host

#######################
HOW TO USE SNORT
 YOU CAN CONFIGURE THE DPDK WITH DAQ VAR DPDK_ARGS
 YOU CAN CONFIGURE THE SNORT LOG WITH -A OR -L
#######################
 snort --daq-dir /usr/local/lib/daq/ --daq dpdk -i dpdk0  --daq-var dpdk_args="-c 1" -c snort.lua -R udp.rules  -A alert_csv  -l ./log/alert_csv -z 10
 snort --daq-dir /usr/local/lib/daq/ --daq dpdk -i dpdk0  --daq-var dpdk_args="-c 1" -c snort.lua -R udp.rules    -A u2  -l ./log/u2 -z 10
#######################
HOW TO USE BARNYARD
#######################
 
