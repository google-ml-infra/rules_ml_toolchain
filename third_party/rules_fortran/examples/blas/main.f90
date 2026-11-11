program main
    implicit none

    ! Matrix dimensions
    integer, parameter :: m = 3, n = 3, k = 3

    ! Matrices
    real(8) :: A(m, k), B(k, n), C(m, n)

    ! BLAS parameters
    real(8) :: alpha, beta
    integer :: lda, ldb, ldc

    ! Loop variables
    integer :: i, j

    print *, "BLAS DGEMM Test: C = alpha*A*B + beta*C"
    print *, ""

    ! Initialize matrices
    ! A = [1 2 3]
    !     [4 5 6]
    !     [7 8 9]
    A = reshape([1.0d0, 4.0d0, 7.0d0, &
                 2.0d0, 5.0d0, 8.0d0, &
                 3.0d0, 6.0d0, 9.0d0], [m, k])

    ! B = [1 0 0]
    !     [0 1 0]
    !     [0 0 1]
    B = reshape([1.0d0, 0.0d0, 0.0d0, &
                 0.0d0, 1.0d0, 0.0d0, &
                 0.0d0, 0.0d0, 1.0d0], [k, n])

    ! C = zeros
    C = 0.0d0

    ! BLAS parameters
    alpha = 1.0d0
    beta = 0.0d0
    lda = m
    ldb = k
    ldc = m

    print *, "Matrix A:"
    do i = 1, m
        print '(3F8.2)', (A(i, j), j = 1, k)
    end do
    print *, ""

    print *, "Matrix B:"
    do i = 1, k
        print '(3F8.2)', (B(i, j), j = 1, n)
    end do
    print *, ""

    ! Call DGEMM: C = alpha*A*B + beta*C
    ! DGEMM(TRANSA, TRANSB, M, N, K, ALPHA, A, LDA, B, LDB, BETA, C, LDC)
    call dgemm('N', 'N', m, n, k, alpha, A, lda, B, ldb, beta, C, ldc)

    print *, "Result C = A*B:"
    do i = 1, m
        print '(3F8.2)', (C(i, j), j = 1, n)
    end do
    print *, ""

    ! Verify result (should equal A since B is identity)
    if (all(abs(C - A) < 1.0d-10)) then
        print *, "Test PASSED: C = A*I = A"
    else
        print *, "Test FAILED"
        stop 1
    end if

end program main
