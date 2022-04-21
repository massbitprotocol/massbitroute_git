#!/bin/bash
SITE_ROOT=$(realpath $(dirname $(realpath $0))/..)
cd $SITE_ROOT

repos="git env ssl gitdeploy apideploy gwmandeploy statdeploy"
_passwd() {
	pass=$(
		tr </dev/urandom -dc _A-Z-a-z-0-9 | head -c${1:-32}
		echo
	)
	echo $pass
}
_get_passwd_default() {
	_user="massbit"
	_pass=$(_passwd)
	echo $_user $_pass >data/default.user
}
_get_passwd() {
	_repo=$1
	if [ -f "data/${_repo}.user" ]; then return; fi
	_pass=$(_passwd)

	echo "$_repo $_pass" >data/${_repo}.user
	htpasswd -bc "data/${_repo}_write.htpasswd" "$_repo" "$_pass"
	htpasswd -bc "data/${_repo}.htpasswd" "$_repo" "$_pass"
	htpasswd -b "data/${_repo}.htpasswd" $(cat data/default.user)
}

_repo_add() {
	_repo_name=$1
	mkdir -p data/repo/massbitroute/$_repo_name
	git -C data/repo/massbitroute/$_repo_name --bare init
	git -C data/repo/massbitroute/$_repo_name update-server-info
	chown -R www-data.www-data data/repo/massbitroute/$_repo_name
	chmod -R 777 data/repo/massbitroute/$_repo_name
}
_repo_create() {
	_repo=$1
	_get_passwd $_repo
	_repo_add $_repo

}

_repos_create() {
	git -C data init
	for _repo in $repos; do
		_repo_create $_repo
	done
}
$@
