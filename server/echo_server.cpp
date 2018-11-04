/**
 *
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#include <grpcpp/grpcpp.h>
#include <unistd.h>
#include <string>
#include <fstream>
#include <sstream>
#include <iostream>

#include "echo.grpc.pb.h"
#include "echo_service.hpp"

using grpc::Server;
using grpc::ServerBuilder;


std::string Read(const std::string& filename) {
  std::ifstream file(filename.c_str(), std::ios::in);
	std::stringstream ss;
	if (file.is_open()) {
		ss << file.rdbuf();
		file.close();
	}
	return ss.str();
}

void RunServer() {
  std::string server_address("0.0.0.0:50051");
  server::EchoService service;
  ServerBuilder builder;

	const std::string key = Read("certs/server_key.pem");
	const std::string cert = Read("certs/server_crt.pem");
	const std::string root = Read("certs/CA_crt.pem");
  if (key.empty() | cert.empty() | root.empty()) {
    std::cerr << "Failed to read cert files." << std::endl;
    return;
  }
  grpc::SslServerCredentialsOptions::PemKeyCertPair keycert{key, cert};
	grpc::SslServerCredentialsOptions ssl_opts;
	ssl_opts.pem_root_certs = root;
	ssl_opts.pem_key_cert_pairs.push_back(keycert);
  builder.AddListeningPort(server_address, grpc::SslServerCredentials(ssl_opts));
  // builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());

  builder.RegisterService(&service);
  std::unique_ptr<Server> server(builder.BuildAndStart());
  server->Wait();
}

int main(int argc, char* argv[]) {
  RunServer();
  return EXIT_SUCCESS;
}
