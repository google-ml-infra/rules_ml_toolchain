## Troubleshooting

This page addresses common issues and provides solutions to help you get started or resolve problems.

### 1. CUDA Build Errors

**Problem:** CUDA wheel build failed with the following errors:
```
/usr/include/x86_64-linux-gnu/bits/stdlib.h(37): error: linkage specification is incompatible with previous "realpath" (declared at line 940 of /usr/include/stdlib.h)
   realpath (const char *__restrict __name, char * __restrict const __attribute__ ((__pass_object_size__ (1 > 1))) __resolved) noexcept (true)
   ^

/usr/include/x86_64-linux-gnu/bits/stdlib.h(72): error: linkage specification is incompatible with previous "ptsname_r" (declared at line 1134 of /usr/include/stdlib.h)
   ptsname_r (int __fd, char * const __attribute__ ((__pass_object_size__ (1 > 1))) __buf, size_t __buflen) noexcept (true)
   ^

/usr/include/x86_64-linux-gnu/bits/stdlib.h(91): error: linkage specification is incompatible with previous "wctomb" (declared at line 1069 of /usr/include/stdlib.h)
   wctomb (char * const __attribute__ ((__pass_object_size__ (1 > 1))) __s, wchar_t __wchar) noexcept (true)
   ^
...
```

**Solution:**
Reported error messages are connected to system headers in the /usr/include/ directory and GLIBC version.

While a direct compatibility matrix for NVCC and GLIBC was elusive try to use the cuDNN compatibility table as a 
reference: [Linux versions for cuDNN](https://docs.nvidia.com/deeplearning/cudnn/backend/latest/reference/support-matrix.html#linux)

Building CUDA requires a compatible machine and GLIBC version. For instance, try building on Ubuntu 24.04, which uses 
GLIBC 2.39, as this combination is documented as supported.