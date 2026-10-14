% DGEMM equivalent: C = alpha*A*B + beta*C
A = [1 2 3; 4 5 6; 7 8 9];
B = eye(3);
C = 1.0 * A * B + 0.0 * zeros(3);  % expected: A
disp(C);
