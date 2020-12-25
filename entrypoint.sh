#!/bin/bash

set -eo pipefail

skopeo inspect docker://docker.io/$INPUT_BASEIMAGE | jq -r .Created > baseimage_date &
skopeo inspect docker://docker.io/$INPUT_IMAGE | jq -r .Created > image_date &

if [[ ${INPUT_PYPI:-unset} != unset ]]; then
	INPUT_PYPI=${INPUT_PYPI,,} # make lowercase
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
elif [[ $image_date < $pypi_date ]]; then
	echo ::set-output name=should-update::true
else
	echo ::set-output name=should-update::false
fi
