# Safe rm
Safe_rm can be used in place of the `rm` command to prevent accidental deletion of files. Deleted files are temporarily stored in the backup directory. It can also be used to restore files from backups.\
\
(**This program works on macOS.**)

## How to Use
It is recommended to create a symbolic link to `srm.sh` after cloning the repository.
```bash
# If the repository is cloned to the home
ln -si $HOME/safe_rm/srm.sh /usr/local/bin/srm
```

### Delete Files
```
srm file1 file2
```

### Show Backups
It shows indexes, original file paths and backups.
```
srm list
```
Output:
```
[  Original  Backup  ]
1  ~/development/file1  file1_240427_23:33:04
2  ~/development/file2  file2_240427_23:33:04
3  ~/development/file3  file3_240427_23:33:04
4  ~/development/file4  file4_240427_23:33:04
5  ~/development/file5  file5_240427_23:33:04
```

### Restore Files
Pass the file indexes as arguments.
```
srm restore 1 3
```

### Delete Files Completely
The `start` option deletes old backups in the background. (Timeout is 2 hours.)
```bash
# Start the process
srm start

# Stop the process
srm stop
```
