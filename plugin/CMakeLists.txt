cmake_minimum_required(VERSION 3.4.3)
project(MyTemplate)

set(CMAKE_CXX_STANDARD 14 CACHE STRING "")
# Build type
if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE
      STRING "Build type (default Debug):" FORCE)
endif()

set(LLVM_INCLUDE_DIR ""
        CACHE STRING "LLVM distribution install path")

set(LLVM_DIR ${LLVM_INCLUDE_DIR}/lib/cmake/llvm)
find_package(LLVM REQUIRED CONFIG)
message("
---------------- LLVM STATUS ----------------
  Build Type  ${CMAKE_BUILD_TYPE}
  Path        ${LLVM_INCLUDE_DIR}
  Version     ${LLVM_PACKAGE_VERSION}
  CMake       ${LLVM_CMAKE_DIR}
  Definitions ${LLVM_DEFINITIONS}
  Includes    ${LLVM_INCLUDE_DIRS}
  Libraries   ${LLVM_LIBRARY_DIRS}
  Targets     ${LLVM_TARGETS_TO_BUILD}
---------------------------------------------"
)

list(APPEND CMAKE_MODULE_PATH ${LLVM_CMAKE_DIR})

set(LLVM_RUNTIME_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/bin)
set(LLVM_LIBRARY_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lib)
include(HandleLLVMOptions)
include(AddLLVM)

add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})
link_directories(${LLVM_LIBRARY_DIRS})

add_subdirectory(test)
