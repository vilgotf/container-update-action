#!/bin/bash

set -Euo pipefail

script_fail() {
	echo "::set-output name=should-update::false"
	echo script failed, check your settings
	exit 1
}

trap script_fail ERR

source data

$debug && echo enabling debug! && set -x

skopeo inspect docker://docker.io/$baseimage | jq -r .Created > baseimage_date &
skopeo inspect docker://docker.io/$image | jq -r .Created > image_date &

[[ $pypi_project ]] && pypi=true || pypi=false

if $pypi; then
	pypi_data=$(curl -fsSL https://pypi.org/pypi/$pypi_project/json)
	readonly pypi_date=$(jq -r .urls[0].upload_time_iso_8601 <<< $pypi_data)
fi

wait

readonly image_date=$(<image_date)
readonly baseimage_date=$(<baseimage_date)

if [[ $image_date < $baseimage_date ]]; then
	echo "::set-output name=should-update::true"
elif $pypi && [[ $image_date < $pypi_date ]]; then
	echo "::set-output name=should-update::true"
else
	echo "::set-output name=should-update::false"
fi
