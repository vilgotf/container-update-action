#!/bin/bash

set -Eeuo pipefail

script_fail() {
	echo ::set-output name=should-update::false
	echo script failed, check your settings
}

trap script_fail ERR

source data

[[ $debug == true ]] && echo 'enabling debug!' && set -x

skopeo inspect docker://docker.io/$baseimage | jq -r .Created > baseimage_date &
skopeo inspect docker://docker.io/$image | jq -r .Created > image_date &

[[ -n $pypi ]] && USE_PYPI=true || USE_PYPI=false

if [[ $USE_PYPI == true ]]; then
	INPUT_PYPI=${pypi,,} # make lowercase
	pypi_data="$(curl -fsSL https://pypi.org/pypi/$INPUT_PYPI/json)"
	readonly pypi_date=$(jq -r .urls[0].upload_time_iso_8601 <<< $pypi_data)
fi

wait

readonly image_date=$(<image_date)
readonly baseimage_date=$(<baseimage_date)

if [[ $image_date < $baseimage_date ]]; then
	echo ::set-output name=should-update::true
elif [[ $USE_PYPI == true && $image_date < $pypi_date ]]; then
	echo ::set-output name=should-update::true
else
	echo ::set-output name=should-update::false
fi
