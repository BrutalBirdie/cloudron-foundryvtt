# foundryvtt.cloudron.app

## Table of content

- [foundryvtt.cloudron.app](#foundryvttcloudronapp)
  - [Table of content](#table-of-content)
  - [IMPORTANT](#important)
  - [How to install from public image](#how-to-install-from-public-image)
  - [How to build it yourself?](#how-to-build-it-yourself)
    - [Get the release zip](#get-the-release-zip)
    - [Build](#build)
    - [Push](#push)
    - [Install](#install)
    - [Update](#update)

## IMPORTANT

> [!IMPORTANT]
> FoundryVTT needs a license to download and use.
If you do not have a license, this is nothing for you.

## How to install from public image

> [!NOTE]
> In the terminal recording I use the `d20.cloudron.dev` location, please replace with your desired location and domain.

[![asciicast](https://asciinema.org/a/IKH2czAvtzKF9xhE4zrV6k5qe.svg)](https://asciinema.org/a/IKH2czAvtzKF9xhE4zrV6k5qe)

## How to build it yourself?

> [!WARNING]
> If you want to follow with copy-paste, for it to be working you need the `jq` package.

### Get the release zip

Go to <https://foundryvtt.com/> login with your credentials and download the configured version in the [Dockerfile Line 3 : VERSION](./Dockerfile).

Place the file in [docker/app/code/FoundryVTT-$VERSION.zip](./docker/app/code/)

### Build

> [!NOTE]
> Replace `dr.cloudron.dev` with your docker registry domain

```bash
docker build -t dr.cloudron.dev/$(jq -r .id CloudronManifest.json):$(jq -r .version CloudronManifest.json) .
```

### Push

> [!NOTE]
> Replace `dr.cloudron.dev` with your docker registry domain

```bash
docker push dr.cloudron.dev/$(jq -r .id CloudronManifest.json):$(jq -r .version CloudronManifest.json) .
```

### Install

> [!NOTE]
> Replace `dr.cloudron.dev` with your docker registry domain
>
> Also replace `vtt` with your desired location

```bash
cloudron install --location vtt --image dr.cloudron.dev/$(jq -r .id CloudronManifest.json):$(jq -r .version CloudronManifest.json)
```

### Update

> [!NOTE]
> To update the app, you need the [CloudronManifest.json](https://github.com/BrutalBirdie/cloudron-foundryvtt/blob/master/CloudronManifest.json)
> Replace `$LOCATION` with either the app location or the app id

```bash
cloudron update --app $LOCATION --image brutalbirdie/foundryvtt.cloudron.app:1.0.0
```
