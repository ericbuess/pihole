#!/bin/bash

# https://github.com/pi-hole/docker-pi-hole/blob/master/README.md

PIHOLE_BASE="${PIHOLE_BASE:-$(pwd)}"
[[ -d "$PIHOLE_BASE" ]] || mkdir -p "$PIHOLE_BASE" || { echo "Couldn't create storage directory: $PIHOLE_BASE"; exit 1; }

# Note: ServerIP should be replaced with your external ip.
docker run -d \
    --name=pihole \
    --hostname=pi.hole \
    --net=host \
    --restart=always \
    --privileged \
    --cap-add=NET_ADMIN \
    --dns=127.0.0.1 --dns=208.67.222.222 \
    -v "${PIHOLE_BASE}/etc-pihole/:/etc/pihole/" \
    -v "${PIHOLE_BASE}/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
    -e TZ="America/Chicago" \
    -e VIRTUAL_HOST="pi.hole" \
    -e ServerIP="192.168.0.104" \
    -e WEBPASSWORD="changeme" \
    pihole/pihole:latest
    #-e DNSMASQ_USER="pihole" \
    #-e PROXY_LOCATION="pi.hole" \
    #-e VIRTUAL_PORT=80 \
    #-v "${PIHOLE_BASE}/log/pihole.log:/var/log/pihole.log" \
    #-v "${PIHOLE_BASE}/resolv.conf/:/etc/reslov.conf/" \   
    #--dns=208.67.222.222 --dns=208.67.220.220 \
    #-p 53:53/tcp -p 53:53/udp \
    #-p 80:80 \
    #-p 443:443 \


printf 'Starting up pihole container '
for i in $(seq 1 20); do
    if [ "$(docker inspect -f "{{.State.Health.Status}}" pihole)" == "healthy" ] ; then
        printf ' OK'
        echo -e "\n$(docker logs pihole 2> /dev/null | grep 'password:') for your pi-hole: https://${IP}/admin/"
        exit 0
    else
        sleep 3
        printf '.'
    fi

    if [ $i -eq 20 ] ; then
        echo -e "\nTimed out waiting for Pi-hole start, consult check your container logs for more info (\`docker logs pihole\`)"
        exit 1
    fi
done;
