#!/bin/bash
ROOT_DIR=$(realpath $(dirname $(realpath $0))/..)
cd $ROOT_DIR
source $ROOT_DIR/scripts/base.sh

source $ROOT_DIR/.env_raw

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
	if [ ! -f "data/default.user" ]; then
		echo $_user $_pass >data/default.user
	fi
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
	_name=$1
	_repo_name="${_name}.git"
	if [ -f "data/repo/massbitroute/$_repo_name/HEAD" ]; then return; fi
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

_add_hosts() {
	grep "git.$DOMAIN" /etc/hosts >/dev/null
	if [ $? -ne 0 ]; then
		echo "127.0.0.1 git.$DOMAIN" >>/etc/hosts
	fi
}
_repos_create() {
	_get_passwd_default
	_add_hosts
	cd data
	rm -rf .git
	git init
	_git_config
	cat data/gitdeploy.user | while read _u _p; do
		git -C data remote add origin http://$_u:$_p@git.$DOMAIN/massbitroute/${_u}.git
	done

	for _repo in $repos; do
		_repo_create $_repo
	done

	git checkout -b $MBR_ENV &&
		git add -f *.user *.htpasswd &&
		git commit -m update &&
		git push --set-upstream origin $MBR_ENV
	cd -
}
$@
