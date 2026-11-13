program mixed_precision
    implicit none
    real(4) :: a_s(2,2), x_s(2), b_s(2)
    real(8) :: a_d(2,2), x_d(2), b_d(2)
    integer :: ipiv(2), info

    ! Single precision: solve Ax = b
    a_s = reshape([2.0, 1.0, 1.0, 3.0], [2,2])
    b_s = [5.0, 6.0]
    call sgesv(2, 1, a_s, 2, ipiv, b_s, 2, info)
    x_s = b_s
    print '(A,2F8.4)', 'Single: x =', x_s

    ! Double precision: solve Ax = b
    a_d = reshape([2.0d0, 1.0d0, 1.0d0, 3.0d0], [2,2])
    b_d = [5.0d0, 6.0d0]
    call dgesv(2, 1, a_d, 2, ipiv, b_d, 2, info)
    x_d = b_d
    print '(A,2F15.10)', 'Double: x =', x_d
end program
