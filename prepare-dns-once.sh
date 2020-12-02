#!/bin/bash

#https://github.com/pi-hole/docker-pi-hole/#running-pi-hole-docker

#Modern releases of Ubuntu (17.10+) include systemd-resolved
#which is configured by default to implement a caching DNS stub resolver. 
#This will prevent pi-hole from listening on port 53. The stub resolver 
#should be disabled with: 
sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf

#This will not change the nameserver settings, which point to the
#stub resolver thus preventing DNS resolution. Change the 
#/etc/resolv.conf symlink to point to /run/systemd/resolve/resolv.conf, 
#which is automatically updated to follow the system's netplan:
sudo sh -c 'rm /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'

#After making these changes, you should restart systemd-resolved using
sudo systemctl restart systemd-resolved
