#!/usr/bin/env bash

sync=./git_backup
dst="../sync_depositery"
src="../track_folder"

init_test_folder() {
    #prepare desination
    rm -rf "$dst"
    $sync init "$dst"
    $sync track "$src" to_sync

    rm -rf "$src"
    mkdir -p "$src"
    mkdir "$src/A"
    echo A > "$src/A/a"
    mkdir "$src/B"
    echo A > "$src/B/b"
}

backup() {
    $sync backup to_sync
}

restore() {
    $sync restore to_sync
}

add_some_updates() {
    echo B >> "$src/A/a"
    echo B >> "$src/B/b"
}

md5_folder() {
    #should be enough to test integrity
    #NOTE: not sure that find will output filename in the same order
    #=> long way for sorting before aggregating output for md5
    find "$1" -type f |sort | xargs cat |md5sum | awk '{ print $1 }'
}

test_restore_feature() {
    init_test_folder
    backup

    add_some_updates
    backup
    md5_before=$(md5_folder "$src")

    #make local changes (non part of any backup)
    echo noise > "$src/A/a"

    restore
    md5_after=$(md5_folder "$src")

    if [[ $md5_before == $md5_after ]]
    then
        echo "[+] Backup successfuly restored."
    else
        echo "[x] Backup restore failed. Begin to pray"
    fi
}

test_restore_feature
