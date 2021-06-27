#!/bin/bash
# This script runs some common xattr operations
# and saves their output.
# This can be used to generate test cases on
# a system which supports xattr, like macOS or Ubuntu.
# The test cases in the repository were generated with the macOS 11 implementation.

set -euxo pipefail

TESTS=(
	"# New file has no attributes
	xattr file"
	"# Added attribute is listed
	xattr -w test_attr test_val file && xattr file"
	"# Added attribute value is available
	xattr -w test_attr test_val file && xattr -p test_attr file"
	"# Multiple attributes are added and listed successfully
	xattr -w test_attr test_val file && 
	xattr -w test_attr2 test_val2 file &&
	xattr file"
	"# Multiple attributes are added and printed successfully
	xattr -w test_attr test_val file && 
	xattr -w test_attr2 test_val2 file &&
	xattr -p test_attr file &&
	xattr -p test_attr2 file"
	"# Attributes can be deleted
	xattr -w test_attr test_val file && 
	xattr -w test_attr2 test_val2 file &&
	xattr -d test_attr file &&
	xattr -p test_attr2 file &&
	xattr file"
	"# Attributes can be cleared
	xattr -w test_attr test_val file && 
	xattr -w test_attr2 test_val2 file &&
	xattr -c file &&
	xattr file"
)

count=0
for test_case in "${TESTS[@]}"
do
	touch file
	echo "$test_case" > test_$count.in
	eval "$test_case" > test_$count.out
	rm file
	(( count++ ))
done

