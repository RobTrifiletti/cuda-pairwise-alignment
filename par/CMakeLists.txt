cmake_minimum_required(VERSION 2.8)
project(dpc_alignment)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../cmake)
set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/..)

find_package(CUDA 4.1 REQUIRED)

# Compile kernels for shader models 2.0 as default
set(CUDA_NVCC_FLAGS "-gencode=arch=compute_20,code=\"sm_20,compute_20\" -O")

include_directories(
  ${CMAKE_SOURCE_DIR}/../fasta/
  ${CMAKE_SOURCE_DIR}/../scorematrix/
  )

link_directories(
  ${CMAKE_SOURCE_DIR}/../fasta/build/
  ${CMAKE_SOURCE_DIR}/../scorematrix/build/
  )

cuda_add_executable(alignment main.c alignment.cu)

target_link_libraries(alignment 
  fasta
  scorematrix
  )
