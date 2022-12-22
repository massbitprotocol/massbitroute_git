#!/bin/bash
dir=$(dirname $(realpath $0))
_install() {
	apt update
	#apt-add-repository ppa:certbot/certbot
	apt install -y certbot
	# wget https://github.com/joohoi/acme-dns-certbot-joohoi/raw/master/acme-dns-auth.py
	##!/usr/bin/env python3
	chmod +x $dir/acme-dns-auth.py
	cp $dir/acme-dns-auth.py /etc/letsencrypt/
}
_get() {
	domain=$1
	email=product@massbit.io
	mkdir -p /tmp/ssl
	certbot certonly --non-interactive --agree-tos -m $email --manual --manual-auth-hook /etc/letsencrypt/acme-dns-auth.py --manual-public-ip-logging-ok --preferred-challenges dns --debug-challenges -d \*.$domain -d $domain >/tmp/ssl/$domain
}
_get_mydomain() {
	domain=$1
	_get $domain
}
_prepare_gateway() {
	if [ -f "/tmp/ssl_time" ]; then
		t0=$(cat /tmp/ssl_time)
	else
		t0=0
	fi
	_now=$(date +%Y%m%d)
	if [ $_now -eq $t0 ]; then return; fi

	echo $_now >/tmp/ssl_time

	ssldir=/massbit/massbitroute/app/src/sites/services/git/data/ssl
	tmpd=$(mktemp -d)
	mkdir -p $tmpd/{live,archive}
	cp -rf /etc/letsencrypt/archive/{eth,matic}* $tmpd/archive/
	cp -rf /etc/letsencrypt/live/{eth,matic}* $tmpd/live/
	cd $tmpd
	tar -cvzf gateway_ssl.tar.gz *

	cp $tmpd/gateway_ssl.tar.gz $ssldir
	cd $ssldir
	git add .
	git commit -m "$(date) update ssl"
	git push
	rm -rf $tmpd

}
_renew() {
	certbot renew
	_prepare_gateway
}
$@

