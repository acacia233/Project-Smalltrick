#!/bin/bash

function Entrance {
    echo -e " [Info] One-Click Optimization for TCP Performance"
    echo -e " [Info] OpenSource:https://github.com/acacia233/Project-Smalltrick"
    echo -e " [Info] Telegram Channel:https://t.me/cutenicobest"
    Optimized
}

function Optimized {
    echo -e " Press Ctrl + C to exit the Script..."
    read -p " Enter your Target Latency (ms): " Latency
    read -p " Enter your Target Speed (Mbps): " PortSpeed
    BDP=`expr $Latency \* $PortSpeed / 1000 / 8 \* 1024 \* 1024`
    TotalMemory=$(free -m | awk '/Mem/ {print $2}')
    Memory_Low=`expr $TotalMemory \* 13`
    Memory_Medium=`expr $TotalMemory \* 18`
    Memory_High=`expr $TotalMemory \* 27`
    echo -e "net.ipv4.tcp_window_scaling = 1" >> /etc/sysctl.conf
    echo -e "net.core.default_qdisc = fq" >> /etc/sysctl.conf
    echo -e "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
    echo -e "net.core.wmem_max = $BDP" >> /etc/sysctl.conf
    echo -e "net.core.rmem_max = $BDP" >> /etc/sysctl.conf
    echo -e "net.ipv4.tcp_rmem= 1024 49152 $BDP" >> /etc/sysctl.conf
    echo -e "net.ipv4.tcp_wmem= 1024 49152 $BDP" >> /etc/sysctl.conf
    echo -e "net.ipv4.tcp_mem = $Memory_Low $Memory_Medium $Memory_High" >> /etc/sysctl.conf
    sysctl -p > /dev/null
    echo -e " [Info] Enjoy!"
}

Entrance