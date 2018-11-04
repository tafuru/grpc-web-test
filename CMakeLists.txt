cmake_minimum_required(VERSION 3.2.0)
project(grpc_web_test)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(cmake/CompileOptions.cmake)

include(cmake/Dependencies.cmake)

set(BUILD_SRC_DIR ${CMAKE_BINARY_DIR}/server/src)
add_custom_command(OUTPUT ${BUILD_SRC_DIR}
  COMMAND mkdir -p ${BUILD_SRC_DIR}
)
set(PROTO_FILES
  ${CMAKE_SOURCE_DIR}/protos/echo.proto
)
set(GRPC_PB_SRCS
  ${BUILD_SRC_DIR}/echo.grpc.pb.h
  ${BUILD_SRC_DIR}/echo.grpc.pb.cc
)
add_custom_command(OUTPUT ${GRPC_PB_SRCS}
  COMMAND ${PROTOC} -I ${CMAKE_SOURCE_DIR}/protos --grpc_out=${BUILD_SRC_DIR} --plugin=protoc-gen-grpc=${GRPC_CPP_PLUGIN_PATH} ${PROTO_FILES}
  DEPENDS protobuf_project ${BUILD_SRC_DIR} ${PROTO_FILES}
)
set(PB_SRCS
  ${BUILD_SRC_DIR}/echo.pb.h
  ${BUILD_SRC_DIR}/echo.pb.cc
)
add_custom_command(OUTPUT ${PB_SRCS}
  COMMAND ${PROTOC} -I ${CMAKE_SOURCE_DIR}/protos --cpp_out=${BUILD_SRC_DIR} ${PROTO_FILES}
  DEPENDS protobuf_project ${BUILD_SRC_DIR} ${PROTO_FILES}
)
set(SRCS
  ${CMAKE_SOURCE_DIR}/server/echo_server.cpp
  ${CMAKE_SOURCE_DIR}/server/echo_service.cpp
)
add_executable(echo_server
  ${SRCS}
  ${PB_SRCS}
  ${GRPC_PB_SRCS}
)
target_include_directories(echo_server PRIVATE
  ${BUILD_SRC_DIR}
  ${ThirdParty_INCLUDE_DIRS}
)
target_link_libraries(echo_server
  ${ThirdParty_LIBRARIES}
)
