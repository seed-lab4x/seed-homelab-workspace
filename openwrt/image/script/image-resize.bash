#!/bin/bash

set -e

_usage() {
	echo "env undefined 'RESIZER_SIZE' or 'RESIZER_PATH'"
	echo "Usage: $0 [/path/to/image-resize.env]"
	exit 1
}

source_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

[[ -z "$config_file" ]] && config_file=$1
[[ -z "$config_file" ]] && config_file="$source_directory/image-resize.env"
if [[ -f "$config_file" ]];
then
	source "$config_file"
fi

[[ -z "$RESIZER_SIZE" || -z "$RESIZER_PATH" ]] && _usage
[[ -z "$RESIZER_REGEX" ]] && RESIZER_REGEX='.*\.img\.gz$'
[[ -z "$RESIZER_OUTPUT_MODE" ]] && RESIZER_OUTPUT_MODE=copy

RESIZER_FILES_ALL=()
RESIZER_FILES_ARCHIVES=()
RESIZER_FILES_UNARCHIVES=()
RESIZER_FILES_IMAGE=()

if [[ -n "$RESIZER_FILES" ]];
then
	while IFS= read -r file;
	do
		[[ -n "$file" && "$file" != "[]" ]] && RESIZER_FILES_ALL+=("$file")
	done <<< "$RESIZER_FILES"
fi

while IFS= read -r -d '' file;
do
	[[ "$file" =~ $RESIZER_REGEX ]] && RESIZER_FILES_ALL+=("$file")
done < <( find "$RESIZER_PATH" -type f -print0 )

for file in "${RESIZER_FILES_ALL[@]}";
do
	if [[ "$file" =~ \.gz$ ]];
	then
		RESIZER_FILES_ARCHIVES+=("$file")
		RESIZER_FILES_IMAGE+=("${file%.gz}")
	else
		RESIZER_FILES_UNARCHIVES+=("$file")
		RESIZER_FILES_IMAGE+=("$file")
	fi
done

for file in "${RESIZER_FILES_ARCHIVES[@]}";
do
	echo "Unarchive: $file"
	gzip -dkqf "$file" || true
done

for file in "${RESIZER_FILES_IMAGE[@]}";
do
	echo "Resize: $file -> $RESIZER_SIZE"
	qemu-img resize -f raw "$file" "$RESIZER_SIZE"
done

if [[ -n "$RESIZER_OUTPUT_DEST" ]];
then
	mkdir -p "$RESIZER_OUTPUT_DEST"

	for file in "${RESIZER_FILES_IMAGE[@]}";
	do
		echo "Copy: $file -> $RESIZER_OUTPUT_DEST"
		cp "$file" "$RESIZER_OUTPUT_DEST"
	done

	if [[ "$RESIZER_OUTPUT_MODE" == "move" ]];
	then
		for file in "${RESIZER_FILES_IMAGE[@]}";
		do
			echo "Remove: $file"
			rm -f "$file"
		done
	fi
fi
