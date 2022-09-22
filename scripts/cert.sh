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
	certbot certonly --manual --manual-auth-hook /etc/letsencrypt/acme-dns-auth.py --preferred-challenges dns --debug-challenges -d \*.$domain -d $domain
}
_get_mydomain(){
    domain=$1
    _get $domain
}
_renew() {
	certbot renew
}
$@
