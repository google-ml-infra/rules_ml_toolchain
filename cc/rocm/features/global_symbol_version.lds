# Assign a symbol version to every exported symbol.
# This is the cheapest option to make sure exported
# llvm symbols don't clash with those of ROCm's libLLVM.so
XLA_TEST {
  global: *;
};
