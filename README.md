Git Based Backup Tool
=====================

Little script aiming to combine power of git to track history on backup and rsync for minimizing data transfer

Warning
-------

Work in progress and partially untested. Use this for test or development purpose only at this time.

Usage
-----
    
    # Init a super repositery which will contains all further backups
    $ git_backup init /extern/drive/backup 

    # Track some folder for which you want to keep history backup
    $ git_backup track /home/user/some/local/folder alias_for_folder
    
    # Launch periodic backup for a tracked folder
    $ git_backup backup alias_for_folder

    # Restore last known backup for a tracked folder
    $ git_backup restore alias_for_folder

Todo
----

* Allow to forget old backup 
* Allow to sync on remote machine
* Allow multiple sync repo
* ...

