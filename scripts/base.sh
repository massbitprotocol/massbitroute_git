#!/bin/bash
SITE_ROOT=$(realpath $(dirname $(realpath $0))/..)

_git_config() {

	cat >$HOME/.gitconfig <<EOF
   [http]
        sslverify = false
    [user]
	email = baysao@gmail.com
	name = Baysao
EOF

}

_git_clone() {
	_url=$1
	_dir=$2
	_branch=$3
	if [ -z "$_branch" ]; then _branch=$MBR_ENV; fi

	mkdir -p $_dir

	if [ ! -d "$_dir" ]; then
		if [ -d "${_dir}.backup" ]; then rm -rf ${_dir}.backup; fi
		mv $_dir ${_dir}.backup
		git clone --depth 1 -b $_branch $_url $_dir

	else

		git -C $_dir pull origin $_branch

	fi

}

_update_sources() {
	_git_config
	_is_reload=0
	branch=$MBR_ENV
	for _pathgit in $@; do
		_path=$(echo $_pathgit | cut -d'|' -f1)
		git config --global --add safe.directory $_path
		_url=$(echo $_pathgit | cut -d'|' -f2)
		_branch=$(echo $_pathgit | cut -d'|' -f3)
		if [ -z "$_branch" ]; then _branch=$branch; fi
		if [ ! -d "$_path/.git" ]; then
			git clone $_url $_path -b $_branch
			git -C $_path fetch --all
			git -C $_path branch --set-upstream-to=origin/$_branch
			_is_reload=1
		else

		git -C $_path checkout $_branch

		tmp="$(git -C $_path pull 2>&1)"


		fi

	done
	return $_is_reload
}
loop() {
	while true; do
		$0 $@
		sleep 3
	done

}
_timeout() {
	t=$1
	if [ -n "$t" ]; then
		shift
		timeout $t $0 $@
	else
		$0 $@
	fi
}
