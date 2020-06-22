# RISC-V LLVM SDK

## How to Build RISC-V LLVM
```bash
# Test on Ubuntu18.04.4
$ sudo apt install binutils build-essential libtool texinfo gzip zip unzip patchutils curl git \
  make cmake ninja-build automake bison flex gperf grep sed gawk python bc zlib1g-dev \
  libexpat1-dev libmpc-dev libglib2.0-dev libfdt-dev libpixman-1-dev 
  # Build Release Version by default
$ make
```

## Generate a LLVM Pass
```bash
# Step 1. Add your pass name to llvm_pass_pipe in Makefile, use commas to seperate
# e.g. llvm_pass_pipe=pass1,pass2

# Step 2.
$ make init-plugin 
```

## Write a LLVM Pass
See Office documents.

## Compile a LLVM Pass
```bash
# Step 1. Update CMakeLists.txt in plugin
# Add `add_subdirectory(pass_name)` in the end

# Step 2.
$ make plugin
```

## Run a LLVM Pass
```bash
export PATH=$PATH:<path/to/toolchain>/bin
# Method I
clang -S -emit-llvm test.c -o test.ll
opt -load-pass-plugin=LLVMpass_name.so -passes=pass_name test.ll

# Method II
clang -Xclang -load -Xclang LLVMpass_name.so test.c
```



