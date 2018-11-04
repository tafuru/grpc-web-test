#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0);pwd)
BUILD_DIR=$SCRIPT_DIR/build

mkdir -p $BUILD_DIR && cd $BUILD_DIR
cmake .. -DCMAKE_BUILD_TYPE=Release
JOBS=$(grep -c ^processor /proc/cpuinfo)
make -j$JOBS

PROTO=$BUILD_DIR/protobuf_project-prefix/bin/protoc
OUT_DIR=$BUILD_DIR/client/src
PROTOC_GEN_GRPC_WEB=$BUILD_DIR/protoc-gen-grpc-web
PROTO_DIR=$SCRIPT_DIR/protos
SRC=$PROTO_DIR/echo.proto

mkdir -p $OUT_DIR
$PROTO -I $PROTO_DIR --js_out=import_style=commonjs,binary:$OUT_DIR $SRC
$PROTO -I $PROTO_DIR --grpc-web_out=import_style=typescript,mode=grpcwebtext:$OUT_DIR --plugin=protoc-gen-grpc-web=$PROTOC_GEN_GRPC_WEB $SRC
