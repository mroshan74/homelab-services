# Homer: An easy access links dashboard
_A dead simple static HOMepage for your servER to keep your services on hand, from a simple yaml configuration file._

## Guides
- [Github](https://github.com/bastienwirtz/homer)
- [Youtube](https://www.youtube.com/watch?v=9iTPm45EmxM)

## Docker

By default, the Docker will expose port 8080, so change this within the
Dockerfile if necessary. When ready, simply use the Dockerfile to
build the image.

```sh
docker run -d \
  -p 8080:8080 \
  -v </your/local/assets/>:/www/assets \
  --restart=always \
  b4bz/homer:latest
```

This will create the homer image and pull in the necessary dependencies.

Once done, run the Docker image and map the port to whatever you wish on
your host. In this example, we simply map port 8000 of the host to
port 8080 of the Docker (or whatever port was exposed in the Dockerfile)

## Troubleshoot
[Can't write to host due to write permission issue](https://github.com/bastienwirtz/homer/blob/main/docs/troubleshooting.md#my-docker-container-refuse-to-start--is-stuck-at-restarting)
```sh
chown -R 1000:1000 /your/assets/folder/
OR
chown -R ${UID}:${GID} /your/assets/folder/
```
> Note: If `chown` doesn't work, run it on `sudo`
