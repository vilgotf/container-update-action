# Container update action

This action returns true if the baseimage is newer than the image or if the pypi project is newer than the image.
Note that it currently only checks dockerhub images.

## Inputs

### `baseimage`

**Required** Baseimage of the container. Should be formated as "author/image:tag" or "library/image:tag" for base images.

### `image`

**Required** Image of the container. Should be formated as "author/image:tag"

### `debug`

Set to true to enable debuging, defalts to false

### `pypi`

**Optional** Pypi project name

## Outputs

### `should-update`

Returns 'true' or 'false'
