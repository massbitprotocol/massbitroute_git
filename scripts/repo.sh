#!/bin/bash
SITE_ROOT=$(dirname $(realpath $0))
cd $SITE_ROOT
_add() {
	_repo_name=$1
	mkdir -p $_repo_name
	cd $_repo_name
	git --bare init
	git update-server-info
	chown -R www-data.www-data .
	chmod -R 777 .
}
