! solve Ax = b using Cholesky decomposition (DPOTRF + DPOTRS)
! A = [4 2 1; 2 5 3; 1 3 6] (SPD), x = [1 2 3]

program main
    implicit none
    integer, parameter :: N = 3, NRHS = 1
    integer :: INFO, i
    double precision :: A(N,N), B(N,NRHS), x_true(N), max_error

    A = reshape([4d0, 2d0, 1d0, &
                 2d0, 5d0, 3d0, &
                 1d0, 3d0, 6d0], [N, N])

    ! b = A * [1, 2, 3]'
    B(:,1) = [11d0, 21d0, 25d0]
    x_true = [1d0, 2d0, 3d0]

    call DPOTRF('L', N, A, N, INFO)
    if (INFO /= 0) then
        print *, "DPOTRF failed, INFO =", INFO
        stop 1
    end if

    call DPOTRS('L', N, NRHS, A, N, B, N, INFO)
    if (INFO /= 0) then
        print *, "DPOTRS failed, INFO =", INFO
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
