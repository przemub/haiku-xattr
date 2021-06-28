#!/bin/bash
set -eo pipefail

[[ -n "${DEBUG:-}" ]] && set -x

GREEN='\033[0;32m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

failed=0
succeeded=0
for in_file in test_*.in
do
	bsd_out_file=${in_file//.in}.out
	haiku_out_file=${in_file//.in}.haiku
	test_number=${in_file//.in}
	test_number=${test_number##test_}

	# Get the comment line of the test
	IFS=$'\n' read -r comment < "$in_file"
	comment=${comment### }
	
	echo -n "Running test $test_number: $comment..."

	touch file
	bash "$in_file" > "$haiku_out_file"
	rm file
	
	diff=$(diff "$bsd_out_file" "$haiku_out_file" || true)
	if [ -z "$diff" ]
	then
		echo -e "\rRunning test $test_number: $comment [ ${GREEN}OK${NO_COLOR} ]"
		rm "$haiku_out_file"
		((succeeded+=1))
	else
		echo -e "\rRunning test $test_number: $comment [ ${RED}FAILED${NO_COLOR} ]\nThe difference is:\n$diff"
		((failed+=1))
	fi
done

if [[ $failed -gt 0 ]]
then
	echo -e "${RED}FAILED.${NO_COLOR} $failed tests failed, $succeeded tests succeeded."
	exit $failed
else
	echo -e "${GREEN}SUCCESS.${NO_COLOR} $failed tests failed, $succeeded tests succeeded."
	exit 0
fi

