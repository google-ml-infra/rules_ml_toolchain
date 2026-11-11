! solve Ax = b using DGESV (LU factorization)
! A = [2 1 -1; -3 -1 2; -2 1 2], x = [1 2 3]

program main
    implicit none
    integer, parameter :: N = 3, NRHS = 1
    integer :: INFO, IPIV(N), i
    double precision :: A(N,N), B(N,NRHS), x_true(N), max_error

    A = reshape([2d0, -3d0, -2d0, &
                 1d0, -1d0,  1d0, &
                -1d0,  2d0,  2d0], [N, N])

    ! b = A * [1, 2, 3]'
    B(:,1) = [1d0, 1d0, 6d0]
    x_true = [1d0, 2d0, 3d0]

    call DGESV(N, NRHS, A, N, IPIV, B, N, INFO)

    if (INFO /= 0) then
        print *, "DGESV failed, INFO =", INFO
        stop 1
    end if

    print *, "Solution:"
    do i = 1, N
        print '(A,I1,A,F12.6,A,F12.6,A)', &
            "  x(", i, ") = ", B(i,1), "  (expected: ", x_true(i), ")"
    end do

    max_error = maxval(abs(B(:,1) - x_true))
    print '(A,ES10.2)', "max error: ", max_error
    if (max_error > 1d-10) stop 1

end program main
