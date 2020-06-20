#!/usr/bin/python3
# -*- coding: utf-8 -*-

import argparse, os
from string import Template



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--dest', '-d', type=str, required = True, help="Template Pass install directory")
    parser.add_argument('--pipe', '-p', type=str, required = True, help="Pass pipeline e.g. HelloWorld,OpcodeCount")
    args = parser.parse_args()

    print("[Tplt] Create Pass Template in " + args.dest)
    for p in args.pipe.split(','):
        if os.path.exists(args.dest + '/' + p):
            print("[Tplt] " + p + " exists, pass")
        else:
            os.mkdir(args.dest + '/' + p) 
            with open(args.dest + '/' + p +'/CMakeLists.txt', 'w', encoding='utf-8') as f:
                res = Template("add_llvm_library( LLVM$name MODULE $name.cpp )").safe_substitute(name=p)
                f.write(res)
            with open(args.dest + '/' + p +'/' + p + '.cpp', 'w', encoding='utf-8') as f:
                res = Template('''
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "$name"

namespace {
	struct $name : PassInfoMixin<$name> {
	  // Main entry point, takes IR unit to run the pass on (&F) and the
	  // corresponding pass manager (to be queried if need be)
	  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {
		  errs() << "[$name] ";
		  errs().write_escaped(F.getName()) << '\\n';
	    return PreservedAnalyses::all();
	  }
	};


}

llvm::PassPluginLibraryInfo get$namePluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "$name", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "$name") {
                    FPM.addPass($name());
                    return true;
                  }
                  return false;
                });
          }};
}

extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  return get$namePluginInfo();
}
                ''').safe_substitute(name=p)
                f.write(res)
                print("[Tplt] " + p + " create")
            
        

