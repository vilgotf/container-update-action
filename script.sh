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
	pypi_data="$(curl -s https://pypi.org/rss/project/${INPUT_PYPI}/releases.xml)"
	date_unformated="$(echo "$pypi_data" | grep -m 1 -oP "<pubDate>\K(\w|,| |:)*")"
	date_formated=$(date -ud "$date_unformated" --iso-8601=seconds)
	readonly pypi_date=${date_formated%%+}
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
