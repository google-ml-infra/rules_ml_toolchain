% DGESVD equivalent: A = U * diag(S) * V'
A = [1 2 3; 4 5 6; 7 8 10];
[U, S, V] = svd(A);
disp(diag(S));  % singular values
fprintf('reconstruction error: %e\n', max(abs(A - U*S*V'), [], 'all'));
