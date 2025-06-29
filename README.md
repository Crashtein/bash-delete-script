# bash-delete-script
Scipt for removing "older/newer than" files in OS based on modification time

## Options
```
$ bash delete-files -h
This script deletes files that meet --older (than) and --newer (than) criteria
-p <path> for finding files
--older <time>[s/m/h/d] optional, would delete files older than
--newer <time>[s/m/h/d] optional, would delete files newer than
--shift <time>[s/m/h/d] optional, simulates running this script in future or in past
-D optional, if passed it will delete files that meet --newer and --older criteria, if not passed script will run in dry mode
-r optional, if passed it will look for files recursive
-h prints this help
```

## Example of raw usage
>bash delete-files.sh --newer 2d --older 10h --shift 11h -p /testPath -r

- will simulate deleting files in path `-p /testPath` wchich are newer than `--newer 2d` and older than `--older 10h` based on **file modification time**
- will be run as it was time in future `--shift 11h`
- will look for files recursive `-r`
- you can add `-D` to perform real deleting on found files

## Testing
There is `test-script.sh` for testing of `delete-files.sh` script.
This script makes temporary directory and subdirectory with files then it tests example parameters for correct deleting. 

## Example with cron
Run crontab for editing:</br>
>crontab -e

Paste cron command, adjust for yourself, i.e: cron for everyday at 12:00:</br>
```
0 12 * * * bash /script-absolute-path/delete-files.sh --newer 2d --older 10h -p /path-to-scan-for-delete -r -D
```
cron for exacly evert 2 day at 12:00, begining from 2025-01-01:</br>
```
0 12 * * * [ $(( ( $(date +\%s) - $(date -d 2025-01-01 +\%s) ) / 86400 \% 2 )) -eq 0 ] && bash /script-absolute-path/delete-files.sh --newer 2d --older 10h -p /path-to-scan-for-delete -r -D
```
Test above cron command for exacly every 2 days in terminal:</br>
```
[ $(( ( $(date +%s) - $(date -d 2025-06-16 +%s) ) / 86400 % 2 )) -eq 0 ] && echo "Good day for run :)" || echo "Not today ;)"
```

Change reference date 2025-06-16 for testing purposes
