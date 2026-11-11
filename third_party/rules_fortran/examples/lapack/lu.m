% DGESV equivalent: solve Ax = b (LU factorization)
A = [2 1 -1; -3 -1 2; -2 1 2];
b = [1; 1; 6];
x = A \ b;  % expected: [1; 2; 3]
disp(x);
