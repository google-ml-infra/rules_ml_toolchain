# Reference BLAS

DGEMM (matrix multiplication) example + full BLAS Level 1/2/3 test suite.

```
bazel test //blas:all --test_output=all
```

### DGEMM output

```
 BLAS DGEMM Test: C = alpha*A*B + beta*C

 Matrix A:
    1.00    2.00    3.00
    4.00    5.00    6.00
    7.00    8.00    9.00

 Matrix B:
    1.00    0.00    0.00
    0.00    1.00    0.00
    0.00    0.00    1.00

 Result C = A*B:
    1.00    2.00    3.00
    4.00    5.00    6.00
    7.00    8.00    9.00

 Test PASSED: C = A*I = A
```

See `main.m` for MATLAB equivalent.

### Netlib test suite

Full [BLAS test suite from Netlib](https://www.netlib.org/blas/), built from source, across all four precisions (s/d/c/z):

- Level 1 (vector): `sblat1`, `dblat1`, `cblat1`, `zblat1`
- Level 2 (matrix-vector): `sblat2`, `dblat2`, `cblat2`, `zblat2`
- Level 3 (matrix-matrix): `sblat3`, `dblat3`, `cblat3`, `zblat3`
