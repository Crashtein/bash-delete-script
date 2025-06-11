#!/bin/bash
mkdir -p test/testrecursive
touch test/test1
touch test/test2
touch test/testrecursive/test1
touch test/testrecursive/test2

OLDER=10h
NEWER=2d

echo "Test params: --newer $NEWER and --older $OLDER"
echo "Found directories:"
find test -type d
echo "Founf files:"
find test -type f
echo "Testing for too new files (should have no output)"
bash delete-files.sh --newer $NEWER --older $OLDER -p test -r
echo "Testing for too old files (should have no output)"
bash delete-files.sh --newer $NEWER --older $OLDER --shift 3d -p test -r
echo "Testing with available files for delete (non recursive)"
bash delete-files.sh --newer $NEWER --older $OLDER --shift 1d -p test
echo "Testing with available files for delete (recursive)"
bash delete-files.sh --newer $NEWER --older $OLDER --shift 1d -p test -r
echo "Performing deletes (non recursive)"
bash delete-files.sh --newer $NEWER --older $OLDER --shift 1d -p test -D
echo "Found directories:"
find test -type d
echo "Found files:"
find test -type f
echo "Performing deletes (recursive)"
bash delete-files.sh --newer $NEWER --older $OLDER --shift 1d -p test -r -D
echo "Found directories:"
find test -type d
echo "Found files (should not show anything):"
find test -type f

echo "Cleaning up after tests"
rm -r test
