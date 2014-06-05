


#cheese
#!/bin/bash

for ((i = 1, start = 1, end = 60; i <= 120; ++i, start += 60, end += 60)); do
PING_NEXT=`traceroute -m4 mit.edu|tail -1|awk '{ print $4 * 2 }'`
echo $PING_NEXT >> /tmp/PING_NEXT_AVG
sleep 1
done

PING_NEXT_AVG=`awk '{ total += $1; count++ } END { print total/count }' /tmp/PING_NEXT_AVG`
rm -rf /tmp/PING_NEXT_AVG


for ((i = 1, start = 1, end = 60; i <= 120; ++i, start += 60, end += 60)); do
        R1=`cat /sys/class/net/eth0/statistics/rx_packets`
        T1=`cat /sys/class/net/eth0//statistics/tx_packets`
        sleep 1
        R2=`cat /sys/class/net/eth0/statistics/rx_packets`
        T2=`cat /sys/class/net/eth0/statistics/tx_packets`
        TXPPS=`expr $T2 - $T1`
        RXPPS=`expr $R2 - $R1`
        echo $TXPPS >> /tmp/_TX.pps
        echo $RXPPS >> /tmp/_RX.pps
done

TX_AVG=`awk '{ total += $1; count++ } END { print total/count }' /tmp/_TX.pps`
RX_AVG=`awk '{ total += $1; count++ } END { print total/count }' /tmp/_RX.pps`

PACKETS_PER_SECOND=`expr $RX_AVG + $TX_AVG`

for ((i = 1, start = 1, end = 60; i <= 120; ++i, start += 60, end += 60)); do
BUDDIES=`cat /proc/net/sockstat|grep TCP|awk '{ print $9}'`
echo $BUDDIES >> /tmp/sockets_120sec
sleep 1
done

BUD_AVG=`awk '{ total += $1; count++ } END { print total/count }' /tmp/sockets_120sec`

rm -rf /tmp/sockets_120sec

mem_bytes=$(awk '/MemTotal:/ { printf "%0.f",$2 * 1024}' /proc/meminfo)
shmmax=$(echo "$mem_bytes * 0.90" | bc | cut -f 1 -d '.') 
shmall=$(expr $mem_bytes / $(getconf PAGE_SIZE))
max_orphan=$(echo "$mem_bytes * 0.10 / 65536" | bc | cut -f 1 -d '.')
file_max=$(echo "$mem_bytes / 4194304 * 256" | bc | cut -f 1 -d '.')
max_tw=$(($file_max*2))
min_free=$(echo "($mem_bytes / 1024) * 0.01" | bc | cut -f 1 -d '.')

sysctl -w kernel.shmmax=$shmmax
sysctl -w net.core.netdev_max_backlog=8000
sysctl -w net.core.optmem_max=16777216
sysctl -w net.core.rmem_default=16777216
sysctl -w net.core.wmem_default=16777216
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216
sysctl -w net.ipv4.conf.all.arp_filter=1
sysctl -w net.ipv4.conf.all.arp_ignore=1
sysctl -w net.ipv4.tcp_low_latency=0
sysctl -w net.ipv4.tcp_mem="16777216 16777216 16777216"
sysctl -w net.ipv4.tcp_reordering=3
sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216"
sysctl -w net.ipv4.tcp_wmem="4096 87380 16777216"
sysctl -w net.ipv4.tcp_sack=1
sysctl -w net.ipv4.tcp_timestamps=1
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.tcp_tw_recycle=1
sysctl -w net.ipv4.tcp_congestion_control=westwood
sysctl -w net.ipv4.tcp_no_metrics_save=1
sysctl -w net.ipv4.tcp_moderate_rcvbuf=1
sysctl -w sys.net.ipv4.route.flush=1
sysctl -w net.ipv4.tcp_max_orphans=$max_orphan
sysctl -w net.ipv4.tcp_orphan_retries=1
sysctl -w net.ipv4.tcp_fin_timeout=20
sysctl -w net.ipv4.tcp_max_tw_buckets=$max_tw
sysctl -w net.ipv4.tcp_syncookies=0
sysctl -w net.ipv4.tcp_keepalive_time=600
sysctl -w net.ipv4.tcp_synack_retries=3
sysctl -w net.ipv4.tcp_syn_retries=3
sysctl -w net.ipv4.tcp_rfc1337=1
sysctl -w net.ipv4.ip_local_port_range="1024 65535"
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.inet_peer_gc_mintime=5
sysctl -w net.ipv4.tcp_ecn=0
sysctl -w net.ipv4.tcp_window_scaling=1
sysctl -w net.ipv4.tcp_timestamps=1
sysctl -w net.ipv4.tcp_fack=1
sysctl -w net.ipv4.tcp_dsack=0
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv4.conf.default.rp_filter=0
sysctl -w net.ipv4.tcp_thin_dupack=0
sysctl -w net.ipv4.tcp_thin_linear_timeouts=0

#### SET PATH FOR "if=" to reflect location of seed algorithm
rat-runner link=$PACKETS_PER_SECOND rtt=$PING_NEXT nsrc=$BUD_AVG if=/opt/seed/remyCC.0
#rat-runner link=$PACKETS_PER_SECOND rtt=$PING_NEXT nsrc=$BUD_AVG if=~/remyCC.0
