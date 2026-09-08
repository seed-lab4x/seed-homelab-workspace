#!/bin/bash

set -e

_usage() {
	echo "env undefined 'CONVERTER_TYPE' or 'CONVERTER_PATH'"
	echo "Usage: $0 [/path/to/image-convert.env]"
	exit 1
}

source_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

[[ -z "$config_file" ]] && config_file=$1
[[ -z "$config_file" ]] && config_file="$source_directory/image-convert.env"
if [[ -f "$config_file" ]];
then
	source "$config_file"
fi

[[ -z "$CONVERTER_TYPE" || -z "$CONVERTER_PATH" ]] && _usage
[[ -z "$CONVERTER_REGEX" ]] && CONVERTER_REGEX='.*\.img\.gz$'
[[ -z "$CONVERTER_OUTPUT_MODE" ]] && CONVERTER_OUTPUT_MODE=copy

CONVERTER_FILES_ALL=()
CONVERTER_FILES_ARCHIVES=()
CONVERTER_FILES_UNARCHIVES=()
CONVERTER_FILES_IMAGE=()
CONVERTER_FILES_CONVERTED=()

if [[ -n "$CONVERTER_FILES" ]];
then
	while IFS= read -r file;
	do
		[[ -n "$file" && "$file" != "[]" ]] && CONVERTER_FILES_ALL+=("$file")
	done <<< "$CONVERTER_FILES"
fi

while IFS= read -r -d '' file;
do
	[[ "$file" =~ $CONVERTER_REGEX ]] && CONVERTER_FILES_ALL+=("$file")
done < <( find "$CONVERTER_PATH" -type f -print0 )

for file in "${CONVERTER_FILES_ALL[@]}";
do
	if [[ "$file" =~ \.gz$ ]];
	then
		CONVERTER_FILES_ARCHIVES+=("$file")
		CONVERTER_FILES_IMAGE+=("${file%.gz}")
	else
		CONVERTER_FILES_UNARCHIVES+=("$file")
		CONVERTER_FILES_IMAGE+=("$file")
	fi
done

for file in "${CONVERTER_FILES_ARCHIVES[@]}";
do
	echo "Unarchive: $file"
	gzip -dkqf "$file" || true
done

for file in "${CONVERTER_FILES_IMAGE[@]}";
do
	target="${file%.img}.$CONVERTER_TYPE"

	echo "Convert: $file -> $target"
	qemu-img convert -f raw -O "$CONVERTER_TYPE" "$file" "$target"
	echo "$target"
	CONVERTER_FILES_CONVERTED+=("$target")
done

if [[ -n "$CONVERTER_OUTPUT_DEST" ]];
then
	mkdir -p "$CONVERTER_OUTPUT_DEST"

	for file in "${CONVERTER_FILES_CONVERTED[@]}";
	do
		echo "Copy: $file -> $CONVERTER_OUTPUT_DEST"
		cp "$file" "$CONVERTER_OUTPUT_DEST"
	done

	if [[ "$CONVERTER_OUTPUT_MODE" == "move" ]];
	then
		for file in "${CONVERTER_FILES_IMAGE[@]}";
		do
			echo "Remove: $file"
			rm -f "$file"
		done
	fi
fi
