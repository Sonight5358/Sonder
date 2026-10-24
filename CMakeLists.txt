cmake_minimum_required(VERSION 3.20)

# CXX project only
project(Sonder LANGUAGES CXX)

# Requirements
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Backend library
add_library(SonderBack STATIC src/Socket.cpp)
target_include_directories(SonderBack PUBLIC include)
target_link_libraries(SonderBack PUBLIC ws2_32)

# Executables
add_executable(TCPServer src/Server.cpp)
add_executable(TCPClient src/Client.cpp)
target_link_libraries(TCPServer PRIVATE SonderBack)
target_link_libraries(TCPClient PRIVATE SonderBack)

# Qt client cmake subdirectory
option(SONDER_BUILD_GUI "Build the Qt client" ON)
if (SONDER_BUILD_GUI)
	add_subdirectory(TCPChatClientQt)
endif()

target_compile_definitions(SonderBack PUBLIC NOMINMAX WIN32_LEAN_AND_MEAN)