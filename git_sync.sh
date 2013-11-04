#!/usr/bin/env bash

sync_base=$(cat $HOME/.sync 2> /dev/null)
tracker=$sync_base/.tracks
old_path=$PWD

function go_sync {
	cd "$sync_base"
}

function go_back {
	cd "$old_path"
}

function check_install {
	if [ ! -e $sync_base ]
	then
		mkdir -p $sync_base
	fi

	if [ ! -d $sync_base/.git ]
	then
		go_sync
		echo "Initializing global backup repo"
		git init -q
		go_back
	fi
}


function track {
	if [ ! $# -eq 2 ]
	then
		echo "track <path> <track_name>"
		exit 1
	fi

	folder=$1
	name=$2

	#check track name is not already in use
	if [[ $name =~ "/" ]]
	then
		echo Track name cannot contains any slash
	elif [[ -d $sync_base/$name ]]
	then
		echo "Have already a track name called : $name"
		exit 1
	else
		go_sync
		mkdir "$name"
		echo "$folder=$name" >> $tracker
		git add $name $tracker
		git commit -q -m "Adding new tracking: $name"
		go_back
	fi
}

function backup {
	if [ ! $# -eq 1 ]
	then
		echo "backup <track_name>"
		exit 1
	fi

	name=$1
	folder=$(grep "$name" $tracker | awk -F= '{ print $1 }')
	
	if [[ -e $folder ]]
	then
		#a : archive
		#r : recursive
		#u : update
		#c : skip on checksum and not mod time or size
		#z : compress during transfer
		#NOTE: need to experiment --delete option
		rsync -arcuzv --delete "$folder/" "$sync_base/$name"

		go_sync
		timestamp=$(date "+%Y-%m-%d %H:%M:%S")
		git add -A .
		git commit -q -m "$timestamp"
		go_back
	else
		echo "$folder does not exist on your system"
		exit 1
	fi
}


#DRY
function restore {
	if [ ! $# -eq 1 ]
	then
		echo "restore <track_name>"
		exit 1
	fi

	name=$1
	folder=$(grep "$name" $tracker | awk -F= '{ print $1 }')
	
	[[ ! -e $folder ]] &&  mkdir -p "$folder"

	rsync -arcuzv --delete "$sync_base/$name/" "$folder/"
}

function init {
	if [ $1 ]
	then
		sync_base=$1
	else
		sync_base=$PWD
	fi

	echo $sync_base > $HOME/.sync 
	check_install
}

case $1 in
	"init")
		shift
		init $@
		;;
	"backup")
		shift
		backup $@
		;;
	"restore")
		shift
		restore $@
		;;
	"track")
		shift
		track $@
		;;
	*)
		echo "Usage:"
		;;
esac
