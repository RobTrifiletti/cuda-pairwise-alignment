cmake_minimum_required(VERSION 2.8)
project(dpc_alignment_ref)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../cmake)
set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/..)
add_definitions(-std=c99 -Wall -pedantic -O3)

include_directories(
  "${CMAKE_SOURCE_DIR}/../fasta/"
  )

link_directories(
  "${CMAKE_SOURCE_DIR}/../fasta/build"
  )

add_executable(globalalign globalalign.c)
target_link_libraries(globalalign fasta)