set(ThirdParty_INCLUDE_DIRS "")
set(ThirdParty_LIBRARIES "")

include(ExternalProject)

# c-ares
ExternalProject_Add(c-ares_project
  SOURCE_DIR ${PROJECT_SOURCE_DIR}/third_party/c-ares-cares-1_15_0
  CMAKE_ARGS
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    -DCARES_STATIC=ON
    -DCARES_SHARED=OFF
    -DCARES_BUILD_TOOLS=OFF
  INSTALL_DIR BINARY_DIR
)
ExternalProject_Get_Property(c-ares_project install_dir)
set(c-ares_DIR ${install_dir})
add_library(c-ares STATIC IMPORTED)
set_property(TARGET c-ares
  PROPERTY IMPORTED_LOCATION ${install_dir}/lib/libcares.a
)
add_dependencies(c-ares c-ares_project)
list(APPEND ThirdParty_INCLUDE_DIRS ${install_dir}/include)
list(APPEND ThirdParty_LIBRARIES c-ares)

# Protocol Buffers
ExternalProject_Add(protobuf_project
  SOURCE_DIR ${PROJECT_SOURCE_DIR}/third_party/protobuf-v3.6.1/cmake
  CMAKE_ARGS
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    -Dprotobuf_BUILD_TESTS=OFF
  INSTALL_DIR BINARY_DIR
)
ExternalProject_Get_Property(protobuf_project install_dir)
set(Protobuf_DIR ${install_dir})
add_library(protobuf STATIC IMPORTED)
set_property(TARGET protobuf
  PROPERTY IMPORTED_LOCATION ${install_dir}/lib/libprotobuf.a
)
add_dependencies(protobuf protobuf_project)
add_library(protoc STATIC IMPORTED)
set_property(TARGET protoc
  PROPERTY IMPORTED_LOCATION ${install_dir}/lib/libprotoc.a
)
add_dependencies(protoc protobuf_project)
list(APPEND ThirdParty_INCLUDE_DIRS ${install_dir}/include)
list(APPEND ThirdParty_LIBRARIES protoc protobuf)
set(PROTOC ${install_dir}/bin/protoc)

# gRPC
set(GRPC_DEPEND_DIRS ${CMAKE_PREFIX_PATH} ${c-ares_DIR} ${Protobuf_DIR})
string(REPLACE ";" "|" GRPC_DEPEND_DIRS "${GRPC_DEPEND_DIRS}")
ExternalProject_Add(grpc_project
  SOURCE_DIR ${PROJECT_SOURCE_DIR}/third_party/grpc-v1.16.0
  INSTALL_DIR BINARY_DIR
  DEPENDS c-ares_project protobuf_project
  LIST_SEPARATOR |
  CMAKE_ARGS
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    -DCMAKE_PREFIX_PATH=${GRPC_DEPEND_DIRS}
    -DgRPC_BUILD_CSHARP_EXT=OFF
    -DgRPC_SSL_PROVIDER=package
    -DgRPC_ZLIB_PROVIDER=package
    -DgRPC_CARES_PROVIDER=package
    -DgRPC_PROTOBUF_PROVIDER=package
    -DgRPC_PROTOBUF_PACKAGE_TYPE=CONFIG
)
ExternalProject_Get_Property(grpc_project install_dir)
add_library(grpc STATIC IMPORTED)
set_property(TARGET grpc
  PROPERTY IMPORTED_LOCATION ${install_dir}/lib/libgrpc.a
)
add_dependencies(grpc grpc_project)
add_library(grpc++ STATIC IMPORTED)
set_property(TARGET grpc++
  PROPERTY IMPORTED_LOCATION ${install_dir}/lib/libgrpc++.a
)
add_dependencies(grpc++ grpc_project)
add_library(gpr STATIC IMPORTED)
set_property(TARGET gpr
  PROPERTY IMPORTED_LOCATION ${install_dir}/lib/libgpr.a
)
add_dependencies(gpr grpc_project)
add_library(address_sorting STATIC IMPORTED)
set_property(TARGET address_sorting
  PROPERTY IMPORTED_LOCATION ${install_dir}/lib/libaddress_sorting.a
)
add_dependencies(address_sorting grpc_project)
set(GRPC_CPP_PLUGIN_PATH ${install_dir}/bin/grpc_cpp_plugin)
list(APPEND ThirdParty_INCLUDE_DIRS ${install_dir}/include)
list(INSERT ThirdParty_LIBRARIES 0 grpc++ grpc gpr address_sorting)

# Threads
find_package(Threads REQUIRED)
list(APPEND ThirdParty_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})

# zlib
find_package(ZLIB REQUIRED)
list(APPEND ThirdParty_INCLUDE_DIRS ${ZLIB_INCLUDE_DIRS})
list(APPEND ThirdParty_LIBRARIES ${ZLIB_LIBRARIES})

# gRPC-Web
add_executable(protoc-gen-grpc-web
  ${PROJECT_SOURCE_DIR}/third_party/grpc-web-1.0.0/javascript/net/grpc/web/grpc_generator.cc
)
target_include_directories(protoc-gen-grpc-web PRIVATE
  ${ThirdParty_INCLUDE_DIRS}
)
target_link_libraries(protoc-gen-grpc-web
  ${ThirdParty_LIBRARIES}
)

# OpenSSL
find_package(OpenSSL REQUIRED)
list(APPEND ThirdParty_INCLUDE_DIRS ${OPENSSL_INCLUDE_DIRS})
list(APPEND ThirdParty_LIBRARIES ${OPENSSL_LIBRARIES})
