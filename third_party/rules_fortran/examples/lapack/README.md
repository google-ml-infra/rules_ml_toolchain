# LAPACK

## DGESV (LU factorization)

Solves 3x3 linear system Ax = b with known solution x = [1, 2, 3].

```
bazel run //lapack:lu
```

```
 Solution:
  x(1) =     1.000000  (expected:     1.000000)
  x(2) =     2.000000  (expected:     2.000000)
  x(3) =     3.000000  (expected:     3.000000)
max error:   0.00E+00
```

MATLAB (`lu.m`):

```matlab
>> lu
     1
     2
     3
```

## DPOTRF/DPOTRS (Cholesky)

Same problem via Cholesky decomposition A = LL' (SPD matrix).

```
bazel run //lapack:chol
```

```
 Solution:
  x(1) =     1.000000  (expected:     1.000000)
  x(2) =     2.000000  (expected:     2.000000)
  x(3) =     3.000000  (expected:     3.000000)
max error:   0.00E+00
```

MATLAB (`chol.m`):

```matlab
>> chol
     1
     2
     3
```

## DGESVD (SVD)

Decomposes A = U * diag(S) * V^T and verifies reconstruction.

```
bazel run //lapack:svd
```

```
 Singular values:
  s(1) =    17.412505
  s(2) =     0.875161
  s(3) =     0.196867
reconstruction error:   6.22E-15
```

MATLAB (`svd.m`):

```matlab
>> svd
   17.4125
    0.8752
    0.1969

reconstruction error: 4.884981e-15
```

See `lu.m`, `chol.m`, and `svd.m` for full MATLAB equivalents.

## Netlib test suite

This directory also includes the full [LAPACK test suite from Netlib](https://www.netlib.org/lapack/), built from source -- LIN, EIG, DMD, mixed precision, and RFP routines across all four precisions (s/d/c/z).

```
bazel test //lapack:all
```

Individual tests across all precisions ([#20](https://github.com/miinso/rules_fortran/issues/20)):

```
                        -->   LAPACK TESTING SUMMARY  <--
                Processing LAPACK Testing output
SUMMARY                 nb test run     numerical error         other error
================        ===========     =================       ================
REAL                    1569648         0       (0.000%)        0       (0.000%)
DOUBLE PRECISION        1570470         0       (0.000%)        0       (0.000%)
COMPLEX                 1029730         0       (0.000%)        0       (0.000%)
COMPLEX16               1030797         0       (0.000%)        0       (0.000%)

--> ALL PRECISIONS      5200645         0       (0.000%)        0       (0.000%)
```
