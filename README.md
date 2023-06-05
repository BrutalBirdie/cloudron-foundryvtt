# foundryvtt.cloudron.app

## IMPORTANT

FoundryVTT needs a license to download and use.

If you do not have a licence, this is nothing for you.

> ⚠️ For copy-paste install like bellow you need the `jq` package.

## Get the release zip

Go to <https://foundryvtt.com/> login with your credentials and download the configured version in the [Dockerfile Line 3 : VERSION](./Dockerfile).

Place the file in [docker/app/code/FoundryVTT-$VERSION.zip](./docker/app/code/)

## Build

> ⚠️ Replace `dr.cloudron.dev` with your docker registry domain

```bash
docker build -t dr.cloudron.dev/$(jq -r .id CloudronManifest.json):$(jq -r .version CloudronManifest.json) .
```

## Push

> ⚠️ Replace `dr.cloudron.dev` with your docker registry domain

```bash
docker push dr.cloudron.dev/$(jq -r .id CloudronManifest.json):$(jq -r .version CloudronManifest.json) .
```

## Install

> ⚠️ Replace `dr.cloudron.dev` with your docker registry domain
>
> Also replace `vtt` with your desired location

```bash
cloudron install --location vtt --image dr.cloudron.dev/$(jq -r .id CloudronManifest.json):$(jq -r .version CloudronManifest.json)
```
