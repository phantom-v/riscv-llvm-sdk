# PPProject [kernel Pointer integrity Protecion Project]
# Copyright (C) 2020 by phantom
# Email: admin@phvntom.tech
# This program is open software under MIT License, see http://phvntom.tech/LICENSE.txt

CMAKE := cmake
srcdir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
srcdir := $(srcdir:/=)
wrkdir := $(CURDIR)/build
tmpdir := /tmp

# For newlib, header files are under <toolchain-install-path>/riscv64-unknown-elf/include
#   DDEFAULT_SYSROOT should be set to '<toolchain-install-path>/riscv64-unknown-elf'
# For linux, heasder files are under <toolchain-install-path>/sysroot/usr/include
#   DDEFAULT_SYSROOT should be set to '<toolchain-install-path>/sysroot', !!! NOT riscv64-unknown-linux-gnu !!!
#
# Using clang with -v option, you can get more info to know where clang to find the include directories
llvm_srcdir := $(srcdir)/llvm-project
llvm_wrkdir := $(wrkdir)/llvm
llvm_insdir := $(CURDIR)/toolchain
llvm_sysroot := $(llvm_insdir)/sysroot

llvm_pass_srcdir := $(srcdir)/plugin
llvm_pass_wrkdir := $(wrkdir)/plugin
llvm_pass_test := $(CURDIR)/test

clang := $(llvm_insdir)/bin/clang
opt := $(llvm_insdir)/bin/opt

# Add your pass HERE, use comma to seperate
llvm_pass_pipe := test
llvm_pass_path_templt := -load-pass-plugin LLVMTemplt.so

comma := ,
$(foreach p, $(subst $(comma),$() $(),$(llvm_pass_pipe)), $(eval llvm_pass_load += $(subst Templt,$(p), $(llvm_pass_path_templt)) ))

all: build

$(tmpdir)/swapfile:
	@echo "Extend swap to 15GB ..."
	sudo dd if=/dev/zero of=$(tmpdir)/swapfile bs=1024 count=15000000

extend-swap: $(tmpdir)/swapfile
	sudo mkswap -f $(tmpdir)/swapfile
	sudo swapon $(tmpdir)/swapfile

$(llvm_sysroot):
	mkdir -p $(wrkdir) $(llvm_insdir)
	@( echo "Trying download riscv64-gnu-toolchian in ZJULAN ..."; wget -P $(wrkdir) http://zju.phvntom.tech/doc/riscv64-gnu-toolchian.tar.gz; tar -zxvf $(wrkdir)/riscv64-gnu-toolchian.tar.gz -C $(llvm_insdir)) || \
	( echo "You need to prepare a riscv-gnu-toolchain, which you can from https://github.com/phantom-v/riscv-rss-sdk" && false )
	
# Debug Version needs abot 20GB Memory, Release version needs about 8G Memory
.PHONY: build
build: $(llvm_sysroot) 
	mkdir -p $(llvm_wrkdir) $(llvm_insdir)
	cd $(llvm_wrkdir); $(CMAKE) -G Ninja -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE="Release" \
		-DBUILD_SHARED_LIBS=True -DLLVM_USE_SPLIT_DWARF=True \
		-DLLVM_OPTIMIZED_TABLEGEN=True -DLLVM_BUILD_TESTS=True \
		-DCMAKE_INSTALL_PREFIX=$(llvm_insdir) \
		-DLLVM_DEFAULT_TARGET_TRIPLE=riscv64-unknown-linux-gnu \
		-DLLVM_TARGETS_TO_BUILD="RISCV" \
		-DDEFAULT_SYSROOT=$(llvm_sysroot) \
		$(llvm_srcdir)/llvm
	$(CMAKE) --build $(llvm_wrkdir) --target install

#  If you rebuild llvm-project with custom pass (in-tree), you may got a error about missing "llvm/IR/Attributes.inc"  
#  You should build llvm and clang seperately:
#    # in .../build/llvm
#    $ ninja -t clean
#    $ ninja clangFrontend
#    $ ninja
.PHONY: plugin
plugin: $(llvm_pass_srcdir) $(clang) $(opt)
	mkdir -p $(llvm_pass_wrkdir) $(llvm_pass_test)
	cd $(llvm_pass_wrkdir); $(CMAKE) -DLLVM_INCLUDE_DIR=$(llvm_insdir) $(llvm_pass_srcdir); make
	cp -r $(llvm_pass_wrkdir)/lib $(llvm_insdir)
	echo "#include <stdio.h>\nint foo () {}\nint test () {}\nint main() {\n\tprintf(\"Hello RISCV\");\n\treturn 0;\n}\n" > $(tmpdir)/hello.c
	$(clang) -S -emit-llvm --sysroot=$(llvm_sysroot) $(tmpdir)/hello.c -o $(tmpdir)/hello.ll
	$(opt) $(llvm_pass_load) -passes=$(llvm_pass_pipe) $(tmpdir)/hello.ll --disable-output

.PHONY: init-plugin
init-plugin:
	$(CURDIR)/tools/initpass.py -d $(llvm_pass_srcdir) -p $(llvm_pass_pipe)

.PHONY: clean
clean: 
	rm -rf toolchain $(wrkdir) test




