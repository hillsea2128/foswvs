#!/bin/bash

# Installation and Configuration Script for the NetworkManager-based System
APPDIR=/home/pi/foswvs

ETH0_IP="192.168.1.68/24"
ETH0_GATEWAY="192.168.1.1"
ETH0_DNS="8.8.8.8 8.8.4.4"
WLAN0_IP="10.0.0.1/24"

echo "Updating system and installing required packages..."
sudo apt update && sudo apt install -y hostapd isc-dhcp-server nginx php-fpm php-sqlite3 network-manager

echo "Configuring eth0 with NetworkManager..."
nmcli connection modify "Wired connection 1" ipv4.addresses "$ETH0_IP" \
    ipv4.gateway "$ETH0_GATEWAY" \
    ipv4.dns "$ETH0_DNS" ipv4.method manual
nmcli connection up "Wired connection 1"

echo "Configuring wlan0 as a hotspot with NetworkManager..."
nmcli connection add type wifi ifname wlan0 con-name "Hotspot" ssid "PisoWiFi_ATM"
nmcli connection modify "Hotspot" 802-11-wireless.mode ap 802-11-wireless.band bg \
    ipv4.addresses "$WLAN0_IP" ipv4.method shared
nmcli connection up "Hotspot"

echo "Updating ISC DHCP server configuration..."
sudo cp $APPDIR/conf/dhcpd.conf /etc/dhcp/dhcpd.conf
sudo cp $APPDIR/conf/isc-dhcp-server /etc/default/isc-dhcp-server
sudo systemctl restart isc-dhcp-server

echo "Configuring hostapd..."
sudo cp $APPDIR/conf/hostapd.conf /etc/hostapd/hostapd.conf
sudo systemctl restart hostapd

echo "Configuring iptables for NAT..."
sudo iptables-restore < $APPDIR/conf/iptables.txt

echo "Enabling IP forwarding if not already enabled..."
if [[ $(cat /proc/sys/net/ipv4/ip_forward) == 0 ]]; then
  sudo sysctl -w net.ipv4.ip_forward=1
fi

echo "Configuring Nginx..."
sudo cp $APPDIR/conf/nginx.conf /etc/nginx/nginx.conf
sudo systemctl restart nginx

echo "Setting file permissions..."
sudo chown -R www-data:www-data $APPDIR
sudo chmod -R 755 /home/pi/foswvs
sudo chmod o+x /home /home/pi

sudo chmod +x $APPDIR/api/client

if [ -f $APPDIR/conf/password.sha256 ]; then
  echo "Removing sensitive file: password.sha256"
  sudo rm -f $APPDIR/conf/password.sha256
fi

echo "Configuring user permissions..."
sudo usermod -aG sudo www-data

echo "Adding visudo configuration for passwordless operations..."
echo "www-data ALL=(ALL) NOPASSWD: /sbin/iptables, /bin/systemctl restart isc-dhcp-server, /bin/systemctl restart hostapd" | sudo EDITOR='tee -a' visudo

echo "Creating foswvs.service for systemd..."
sudo bash -c 'cat > /etc/systemd/system/foswvs.service << EOF
[Unit]
Description=FOSWVS Service
After=network.target

[Service]
ExecStart=/home/pi/foswvs/start
WorkingDirectory=/home/pi/foswvs
Restart=always
User=www-data
Group=www-data

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable foswvs.service
sudo systemctl start foswvs.service

echo "Installation and configuration complete."
