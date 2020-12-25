#!/bin/bash

readonly baseimage_date=$(skopeo inspect docker://docker.io/$baseimage | jq .Created)
readonly image_date=$(skopeo inspect docker://docker.io/$image | jq .Created)

if [[ ${pypi:-unset} != "unset" ]]; then
	pypi=${pypi,,} # make lowercase
	pypi_data="$(curl -s https://pypi.org/rss/project/${pypi}/releases.xml)"
	date_unformated="$(echo "$pypi_data" | grep -m 1 -oP "<pubDate>\K(\w|,| |:)*")"
	date_formated=$(date -ud "$date_unformated" --iso-8601=seconds)
	readonly pypi_date=${date_formated%%+}
fi

if [[ $image_date < $baseimage_date ]]; then
	exit 0
#	echo "::set-output name=should-update::true"
elif [[ $image_date < $pypi_date ]]; then
	exit 0
#	echo "::set-output name=should-update::true"
else
	exit 1
#	echo "::set-output name=should-update::false"
fi
