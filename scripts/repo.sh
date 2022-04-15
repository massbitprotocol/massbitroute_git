#!/bin/bash
SITE_ROOT=$(realpath $(dirname $(realpath $0))/..)
cd $SITE_ROOT

#users=(session env api asdf gateway gbc git gwman mkagent monitor node ssl stat apideploy ssh  gwmandeploy statdeploy )
_passwd() {
	pass=$(
		tr </dev/urandom -dc _A-Z-a-z-0-9 | head -c${1:-32}
		echo
	)
	echo $pass
}
_repo_passwd() {
	_repo=$1
	_pass=$(_passwd)
	_massbit_user=$(cat data/.public_user)
	_massbit_pwd=$(cat data/.public_pass)
	echo $_repo $_pass >>data/.passwords
	htpasswd -bc "data/${_repo}_write.htpasswd" "$_repo" "$_pass"
	htpasswd -bc "data/${_repo}.htpasswd" "$_repo" "$_pass"
	htpasswd -b "data/${_repo}.htpasswd" "$_massbit_user" "$massbit_pwd"

	# massbit_pwd=$(echo massbit123 | sha1sum | sed 's/  -//')
	# for user in "${users[@]}"; do
	# 	echo $user
	# 	password=$(echo ${user}${user} | sha1sum | sed 's/  -//')
	# 	htpasswd -bc "${user}_write.htpasswd" "$user" "$password"
	# 	htpasswd -bc "$user.htpasswd" "$user" "$password"
	# 	htpasswd -b "$user.htpasswd" massbit "$massbit_pwd"
	# done
}
_repos_create() {
	_repo_list=(session env api asdf gateway gbc git gwman mkagent monitor node ssl stat apideploy ssh gwmandeploy statdeploy)

}

_repo_add() {
	_repo_name=$1
	mkdir -p $_repo_name
	cd $_repo_name
	git --bare init
	git update-server-info
	chown -R www-data.www-data .
	chmod -R 777 .
}
$@
