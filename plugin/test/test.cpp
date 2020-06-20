
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "test"

namespace {
	struct test : PassInfoMixin<test> {
	  // Main entry point, takes IR unit to run the pass on (&F) and the
	  // corresponding pass manager (to be queried if need be)
	  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {
		  errs() << "[test] ";
		  errs().write_escaped(F.getName()) << '\n';
	    return PreservedAnalyses::all();
	  }
	};


}

llvm::PassPluginLibraryInfo get$namePluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "test", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "test") {
                    FPM.addPass(test());
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
                