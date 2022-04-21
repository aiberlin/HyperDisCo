# HyperDisCo

HyperDisCo implements an Etherpad-like syncing for SuperCollider documents.

## Setup

Start by installing the Quark via

```supercollider
// install quark
Quarks.install("https://github.com/aiberlin/HyperDisCo.git");

// recompile interpreter
thisProcess.recompile;
```

## Available servers

Host | Port | Comment
--- | --- | ---
`bgo.la` | `55555` | Default server - provided by developer
`hyperdisco.dennis-scheiba.com` | `55555` | Provided by developer

## Server setup

If you want to run a server on your own you can use docker for this.
This also allows you to use HyperDisCo in your local area network (LAN) without internet. 

Start by cloning the repository to your local folder

```shell
git clone --recurse-submodules https://github.com/aiberlin/HyperDisCo.git && \
cd HyperDisCo
```

and spin up the server with

```shell
docker-compose up -d
```

where the `-d` flag indicates that the docker container should start as daemon.

Have in mind that the port mapping of the `docker-compose.yml` maps port `55555` to `55550` and `55556` to `55551`.
This is because on macOS the port `55555` is already taken by the operating system and can not be used.
Also, when running on a server, this allows to run the service behind a reverse proxy such as nginx.

If executed on your local machine you should therefore connect to `localhost:55550`.

To stop the server execute

```shell
docker-compose down
```

in the directory of the `docker-compose.yml` file.

## License

GPL
