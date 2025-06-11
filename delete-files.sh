#!/bin/bash

# Parse time to seconds (np. 30s, 5m, 2h, 1d)
parse_duration() {
    local value=${1::-1}
    local unit=${1: -1}
    case "$unit" in
        s) echo "$value" ;;
        m) echo $((value * 60)) ;;
        h) echo $((value * 3600)) ;;
        d) echo $((value * 86400)) ;;
        *) echo "Invalid time unit (available s/m/h/d): $unit" >&2; exit 1 ;;
    esac
}

# Init variables
PATH_ARG=""
OLDER=""
NEWER=""
SHIFT=0
DO_DELETE=0
RECURSIVE=0

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p)
            PATH_ARG="$2"
            shift 2
            ;;
        --older)
            OLDER=$(parse_duration "$2")
            shift 2
            ;;
        --newer)
            NEWER=$(parse_duration "$2")
            shift 2
            ;;
        --shift)
            SIGN=${2:0:1}
            if [[ "$SIGN" == "-" || "$SIGN" == "+" ]]; then
                SHIFT=$(parse_duration "${2:1}")
                [[ "$SIGN" == "-" ]] && SHIFT=$((-SHIFT))
            else
                SHIFT=$(parse_duration "$2")
            fi
            shift 2
            ;;
        -D)
            DO_DELETE=1
            shift
            ;;
        -r)
            RECURSIVE=1
            shift
            ;;
        -h)
            echo "This script deletes files that meet --older (than) and --newer (than) criteria"
            echo "-p <path> for finding files"
            echo "--older <time>[s/m/h/d] optional, would delete files older than"
            echo "--newer <time>[s/m/h/d] optional, would delete files newer than"
            echo "--shift <time>[s/m/h/d] optional, simulates running this script in future or in past"
            echo "-D optional, if passed it will delete files that meet --newer and --older criteria, if not passed script will run in dry mode"
            echo "-r optional, if passed it will look for files recursive"
            echo "-h prints this help"
            exit 1
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Usage: $0 -p <path> [--older <time>] [--newer <time>] [--shift <time>] [-D] [-r]"
            exit 1
            ;;
    esac
done

# Validate path arg if has been passed
if [[ -z "$PATH_ARG" ]]; then
    echo "Usage: $0 -p <path> [--older <time>] [--newer <time>] [--shift <time>] [-D] [-r]"
    exit 1
fi

# Get reference time in UNIX timestamp in seconds
REFERENCE_TIME=$(TZ=Europe/Warsaw date +%s)
REFERENCE_TIME=$((REFERENCE_TIME + SHIFT))

# Set recursive finding if -r passed
if [[ "$RECURSIVE" -eq 1 ]]; then
    FIND_OPTS=""
else
    FIND_OPTS="-maxdepth 1"
fi

# Iterate through found files under path
find "$PATH_ARG" $FIND_OPTS -type f | while read -r file; do
    MOD_TIME=$(stat -c %Y "$file")
    AGE=$((REFERENCE_TIME - MOD_TIME))
    DELETE=""
    # check if file age is older than --older (if --older passed)
    if [[ -n "$OLDER" ]]; then
        if [[ "$AGE" -gt "$OLDER" ]]; then
            DELETE=1
        else
            DELETE=0
        fi
    fi
    # check if file age is newer than --newer (if --newer passed)
    if [[ -n "$NEWER" ]]; then
        if { [[ -z "$DELETE" ]] || [[ "$DELETE" -eq 1 ]]; } && [[ "$AGE" -lt "$NEWER" ]]; then
            DELETE=1
        else
            DELETE=0
        fi
    fi

    if [[ "$DELETE" -eq 1 ]]; then
        if [[ "$DO_DELETE" -eq 1 ]]; then
            echo "[DESTROY MODE] DELETING: $file"
            rm -f "$file"
        else
            echo -n "[DRY MODE] WOULD DELETE: $file, AGE: ${AGE}s"
            if [[ -n "$NEWER" ]]; then
                echo -n ", newer than ${NEWER}s"
            fi
            if [[ -n "$OLDER" ]]; then
                echo -n ", older than ${OLDER}s"
            fi
            echo
        fi
    fi
done
