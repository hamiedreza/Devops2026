
#!/bin/bash

# ==========================================
# Server Health Report
# Linux + Docker + Kubernetes + SSH
# ==========================================

set -u

HOSTNAME=$(hostname)
DATE=$(date '+%Y-%m-%d %H:%M:%S')

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# SSH Cluster Configuration
SERVERS=(
    "server01:192.168.93.149"
    "server02:192.168.93.150"
    "server03:192.168.93.152"
)

SSH_PORT=22
SSH_TIMEOUT=3

# ------------------------------------------
# Print Header
# ------------------------------------------

print_header() {

    echo
    echo "=========================================="
    echo "          SERVER HEALTH REPORT"
    echo "=========================================="

    echo "Hostname : $HOSTNAME"
    echo "Date     : $DATE"
    echo "Kernel   : $(uname -r)"
    echo "OS       : $(. /etc/os-release && echo "$PRETTY_NAME")"
    echo "=========================================="
}

# ------------------------------------------
# Check System Uptime
# ------------------------------------------

check_uptime() {

    echo
    echo "[ SYSTEM UPTIME ]"

    uptime

    echo
    echo "Load Average: $(awk '{print $1, $2, $3}' /proc/loadavg)"
}

# ------------------------------------------
# Check CPU Usage
# ------------------------------------------

check_cpu() {

    echo
    echo "[ CPU USAGE ]"

    CPU_IDLE=$(top -bn1 | awk '
    /Cpu\(s\)/ {
        for (i=1; i<=NF; i++) {
            if ($i ~ /^id/) {
                print $(i-1)
                exit
            }
        }
    }')

    if [[ "$CPU_IDLE" =~ ^[0-9]+([.][0-9]+)?$ ]]; then

        CPU_USAGE=$(awk -v idle="$CPU_IDLE" \
            'BEGIN {printf "%.2f", 100-idle}')

        echo "CPU Usage: ${CPU_USAGE}%"

    else

        echo "Unable to determine CPU usage."

    fi

    echo "CPU Cores: $(nproc)"
}

# ------------------------------------------
# Check Memory Usage
# ------------------------------------------

check_memory() {

    echo
    echo "[ MEMORY USAGE ]"

    free -h

    MEM_USAGE=$(free | awk '
    /^Mem:/ {
        printf "%.2f", (($2-$7)/$2)*100
    }')

    echo
    echo "Memory Usage: ${MEM_USAGE}%"
}

# ------------------------------------------
# Check Disk Usage
# ------------------------------------------

check_disk() {

    echo
    echo "[ DISK USAGE ]"

    df -hT -x tmpfs -x devtmpfs

    echo
    echo "[ DISK WARNINGS ]"

    df -P -x tmpfs -x devtmpfs | awk '
    NR > 1 {
        usage=$5
        gsub("%","",usage)

        if (usage >= 80)
            print "WARNING: " $6 " usage is " usage "%"
    }'
}

# ------------------------------------------
# Check Failed System Services
# ------------------------------------------

check_failed_services() {

    echo
    echo "[ FAILED SYSTEMD SERVICES ]"

    FAILED=$(systemctl --failed --no-legend --no-pager)

    if [[ -z "$FAILED" ]]; then

        echo -e "${GREEN}No failed services found.${NC}"

    else

        echo -e "${RED}$FAILED${NC}"

    fi
}

# ------------------------------------------
# Check Top Processes
# ------------------------------------------

check_top_processes() {

    echo
    echo "[ TOP 5 CPU PROCESSES ]"

    ps -eo pid,comm,%cpu,%mem \
        --sort=-%cpu | head -n 6

    echo
    echo "[ TOP 5 MEMORY PROCESSES ]"

    ps -eo pid,comm,%cpu,%mem \
        --sort=-%mem | head -n 6
}

# ------------------------------------------
# Check Docker
# ------------------------------------------

check_docker() {

    echo
    echo "=========================================="
    echo "             DOCKER HEALTH"
    echo "=========================================="

    if ! command -v docker &>/dev/null; then

        echo "Docker is not installed."
        return

    fi

    if ! docker info &>/dev/null; then

        echo -e "${RED}Docker daemon is unavailable.${NC}"
        return

    fi

    echo "Docker Version: $(docker version --format '{{.Server.Version}}')"

    echo
    echo "[ RUNNING CONTAINERS ]"

    docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

    echo
    echo "[ STOPPED CONTAINERS ]"

    docker ps -a --filter status=exited \
        --format 'table {{.Names}}\t{{.Status}}'
}

# ------------------------------------------
# Check Kubernetes
# ------------------------------------------

check_kubernetes() {

    echo
    echo "=========================================="
    echo "          KUBERNETES HEALTH"
    echo "=========================================="

    if ! command -v kubectl &>/dev/null; then

        echo "kubectl is not installed."
        return

    fi

    if ! kubectl --request-timeout=5s cluster-info &>/dev/null; then

        echo -e "${RED}Kubernetes cluster is unavailable.${NC}"
        return

    fi

    echo
    echo "[ KUBERNETES NODES ]"

    kubectl get nodes -o wide

    echo
    echo "[ NODE STATUS WARNINGS ]"

    kubectl get nodes --no-headers | awk '
    $2 != "Ready" {
        print "WARNING: Node " $1 " status is " $2
        found=1
    }
    END {
        if (!found)
            print "All nodes are Ready."
    }'

    echo
    echo "[ ALL PODS ]"

    kubectl get pods -A

    echo
    echo "[ UNHEALTHY PODS ]"

    kubectl get pods -A --no-headers | awk '
    $4 != "Running" && $4 != "Completed" {
        print
        found=1
    }
    END {
        if (!found)
            print "No unhealthy pods found."
    }'

    echo
    echo "[ SYSTEM PODS ]"

    kubectl get pods -n kube-system

    echo
    echo "[ DEPLOYMENTS ]"

    kubectl get deployments -A

    echo
    echo "[ CLUSTER INFO ]"

    kubectl cluster-info
}

# ------------------------------------------
# Check SSH Connectivity Between Servers
# ------------------------------------------

check_ssh() {

    echo
    echo "=========================================="
    echo "          SSH CONNECTIVITY"
    echo "=========================================="

    echo "Source Server: $HOSTNAME"
    echo "SSH Port     : $SSH_PORT"
    echo

    for SERVER in "${SERVERS[@]}"; do

        SERVER_NAME="${SERVER%%:*}"
        SERVER_IP="${SERVER##*:}"

        echo -n "Checking $SERVER_NAME ($SERVER_IP) ... "

        if command -v nc &>/dev/null; then

            if nc -z -w "$SSH_TIMEOUT" \
                "$SERVER_IP" "$SSH_PORT" &>/dev/null; then

                echo -e "${GREEN}[CONNECTED]${NC}"

            else

                echo -e "${RED}[FAILED]${NC}"

            fi

        elif command -v timeout &>/dev/null; then

            if timeout "$SSH_TIMEOUT" bash -c \
                ':</dev/tcp/$1/$2' _ "$SERVER_IP" "$SSH_PORT" \
                &>/dev/null; then

                echo -e "${GREEN}[CONNECTED]${NC}"

            else

                echo -e "${RED}[FAILED]${NC}"

            fi

        else

            echo -e "${YELLOW}[SKIPPED: No connection tool]${NC}"

        fi

    done

    echo
    echo "SSH connectivity check completed."
}

# ------------------------------------------
# Main Function
# ------------------------------------------

main() {

    print_header

    check_uptime

    check_cpu

    check_memory

    check_disk

    check_failed_services

    check_top_processes

    check_docker

    check_kubernetes

    check_ssh

    echo
    echo "=========================================="
    echo "       HEALTH REPORT COMPLETED"
    echo "=========================================="
}

# ------------------------------------------
# Execute Script
# ------------------------------------------

main

