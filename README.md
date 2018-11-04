# gRPC-Web test
- gRPC backend server (written in C++)
- Envoy proxy
- Front-end JS client

## Install Dependencies
### Backend Server
```shell
$ sudo apt install libssl-dev zlib1g-dev
```
### Client
```shell
$ yarn
```

## Build
```shell
$ git submodule update --init --recursive
$ ./build.sh
```

## Run
### Backend Server
```shell
$ ./build/echo_server
```
### Client
```shell
$ yarn start
```
### Proxy
```shell
$ docker run --rm --add-host=echo_server:<YOUR_HOST_IP> -v $(pwd)/conf:/etc/envoy/conf -p 8080:8080 envoyproxy/envoy /usr/local/bin/envoy --v2-config-only -l info -c /etc/envoy/conf/envoy.yaml
```
