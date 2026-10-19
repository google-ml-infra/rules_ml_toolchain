% DPOTRF/DPOTRS equivalent: solve Ax = b via Cholesky (A = LL')
A = [4 2 1; 2 5 3; 1 3 6];
b = [11; 21; 25];
L = chol(A, 'lower');
x = L' \ (L \ b);  % expected: [1; 2; 3]
disp(x);
