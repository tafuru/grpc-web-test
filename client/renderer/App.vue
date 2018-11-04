<template lang="pug">
#App
  h1 gRPC-Web
</template>

<script lang="ts">
import Vue from 'vue'
import { ComponentOptions } from 'vue'
import * as grpcWeb from 'grpc-web';
import {EchoServiceClient} from '../../build/client/src/EchoServiceClientPb';
import {ServerStreamingEchoRequest, ServerStreamingEchoResponse} from '../../build/client/src/echo_pb';
export interface App extends Vue {
  echoService: EchoServiceClient;
  stream: grpcWeb.ClientReadableStream;
  count: number;
  time: Date;
}
export default {
  data() {
    return {
      count: 0,
      time: Date.now()
    }
  },
  mounted () {
    this.echoService = new EchoServiceClient('http://localhost:8080', null, null);
    const request = new ServerStreamingEchoRequest();
    request.setMessageCount(10000);
    request.setMessageInterval(100);
    request.setMessage('Hello World!');
    this.stram = this.echoService.serverStreamingEcho(request, null);
    this.stram.on('data', (response: ServerStreamingEchoResponse) => {
      const now = Date.now();
      if (1000 < now - this.time) {
        this.time = now;
        console.info(this.count);
        this.count = 0;
      }
      this.count++;
    });
    this.stram.on('status', (status: grpcWeb.Status) => {
      console.info(status.code);
      console.info(status.details);
    });
    this.stram.on('error', (error: grpcWeb.Error) => {
      console.info(error.code);
      console.info(error.message);
    });
  }
} as ComponentOptions<App>
</script>


<style lang="stylus">
@import "nib/index.styl"

global-reset()
</style>

<style lang="stylus" scoped>
#App
  min-width 100vw
  min-height 100vh
  font-family "'Times New Roman', Times, serif"
</style>
