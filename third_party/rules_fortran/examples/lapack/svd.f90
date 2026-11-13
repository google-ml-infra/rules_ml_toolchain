! compute SVD using DGESVD: A = U * diag(S) * V^T
! A = [1 2 3; 4 5 6; 7 8 10]

program main
    implicit none
    integer, parameter :: M = 3, N = 3, K = min(M, N)
    integer :: INFO, i, j, l
    double precision :: A(M,N), A_copy(M,N), S(K)
    double precision :: U(M,M), VT(N,N), WORK(64)
    double precision :: recon(M,N), max_error

    A = reshape([1d0, 4d0, 7d0, &
                 2d0, 5d0, 8d0, &
                 3d0, 6d0, 10d0], [M, N])
    A_copy = A

    call DGESVD('A', 'A', M, N, A, M, S, U, M, VT, N, WORK, 64, INFO)

    if (INFO /= 0) then
        print *, "DGESVD failed, INFO =", INFO
        stop 1
    end if

    print *, "Singular values:"
    do i = 1, K
        print '(A,I1,A,F12.6)', "  s(", i, ") = ", S(i)
    end do

    ! verify: A = U * diag(S) * VT
    recon = 0d0
    do j = 1, N
        do i = 1, M
            do l = 1, K
                recon(i,j) = recon(i,j) + U(i,l) * S(l) * VT(l,j)
            end do
        end do
    end do

    max_error = maxval(abs(recon - A_copy))
    print '(A,ES10.2)', "reconstruction error: ", max_error
    if (max_error > 1d-10) stop 1

end program main
