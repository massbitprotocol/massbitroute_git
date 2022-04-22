#!/bin/bash
ROOT_DIR=$(realpath $(dirname $(realpath $0))/..)

source $ROOT_DIR/scripts/base.sh

source $ROOT_DIR/.env_raw

cd $ROOT_DIR

repos="git env ssl gitdeploy apideploy gwmandeploy statdeploy"
_passwd() {
	pass=$(
		tr </dev/urandom -dc _A-Z-a-z-0-9 | head -c${1:-32}
		echo
	)
	echo $pass
}
_get_passwd_default() {
	if [ ! -f "$ROOT_DIR/data/default.user" ]; then
		_user="massbit"
		_pass=$(_passwd)

		echo $_user $_pass >$ROOT_DIR/data/default.user
	fi
}
_get_passwd() {
	_repo=$1
	if [ -f "$ROOT_DIR/data/${_repo}.user" ]; then return; fi
	_pass=$(_passwd)

	echo "$_repo $_pass" >$ROOT_DIR/data/${_repo}.user
	htpasswd -bc "$ROOT_DIR/data/${_repo}_write.htpasswd" "$_repo" "$_pass"
	htpasswd -bc "$ROOT_DIR/data/${_repo}.htpasswd" "$_repo" "$_pass"
	htpasswd -b "$ROOT_DIR/data/${_repo}.htpasswd" $(cat $ROOT_DIR/data/default.user)
}

_repo_add() {
	_name=$1
	_repo_name="${_name}.git"
	if [ -f "$ROOT_DIR/data/repo/massbitroute/$_repo_name/HEAD" ]; then return; fi
	mkdir -p $ROOT_DIR/data/repo/massbitroute/$_repo_name
	git -C $ROOT_DIR/data/repo/massbitroute/$_repo_name --bare init
	git -C $ROOT_DIR/data/repo/massbitroute/$_repo_name update-server-info
	chown -R www-data.www-data $ROOT_DIR/data/repo/massbitroute/$_repo_name
	chmod -R 777 $ROOT_DIR/data/repo/massbitroute/$_repo_name
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
	_git_config
	_get_passwd_default
	_add_hosts

	for _repo in $repos; do
		_repo_create $_repo
	done

	mkdir -p $ROOT_DIR/data $ROOT_DIR/env

	_reponame=gitdeploy
	_userdir=$ROOT_DIR/data
	_dir=$ROOT_DIR/data
	_git="git -C $_dir"
	if [ ! -d "$_dir/.git" ]; then
		$_git init
		cat $_userdir/${_reponame}.user | while read _u _p; do
			$_git remote add origin http://${_u}:${_p}@git.$DOMAIN/massbitroute/${_u}.git
		done
	else
		cat $_userdir/${_reponame}.user | while read _u _p; do
			$_git remote set-url origin http://${_u}:${_p}@git.$DOMAIN/massbitroute/${_u}.git
		done
		$_git pull

	fi

	$_git checkout -b $MBR_ENV &&
		$_git add -f *.user *.htpasswd &&
		$_git commit -m update &&
		$_git push --set-upstream origin $MBR_ENV
}

$@
