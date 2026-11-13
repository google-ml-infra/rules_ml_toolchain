! compute Dynamic Mode Decomposition eigenvalues using SGEDMDQ
! snapshots f(k) = PHI * lambda^(k-1), lambda = [0.9 0.5 0.2]

program main
    ! Same kind selection as LAPACK's xGEDMD/xGEDMDQ sources, which take it
    ! from an intrinsic module.
    use, intrinsic :: iso_fortran_env, only: real32
    implicit none
    integer, parameter :: wp = real32
    integer, parameter :: M = 5, N = 4, R = 3
    integer :: INFO, K, LWORK, LIWORK, i, j, imax
    integer :: iquery(1)
    integer, allocatable :: IWORK(:)
    real(wp) :: PHI(M,R), lambda(R), F(M,N)
    real(wp) :: X(N,N-1), Y(N,N-1), Z(M,N-1), B(N,N-1)
    real(wp) :: V(N-1,N-1), S(N-1,N-1)
    real(wp) :: REIG(N-1), IMEIG(N-1), RES(N-1)
    real(wp) :: wquery(2), tol, tmp, max_error, max_residual
    real(wp), allocatable :: WORK(:)

    ! three linearly independent modes of a 5-dimensional state
    PHI = reshape([1.0_wp,  1.0_wp,  1.0_wp,  1.0_wp, 1.0_wp, &
                   1.0_wp, -1.0_wp,  1.0_wp, -1.0_wp, 1.0_wp, &
                   1.0_wp,  0.0_wp, -1.0_wp,  0.0_wp, 1.0_wp], [M, R])
    lambda = [0.9_wp, 0.5_wp, 0.2_wp]

    ! trajectory of x(k+1) = A*x(k) started at PHI*[1, 1, 1]', so that the
    ! eigenvalues of A seen by the data are exactly lambda
    do j = 1, N
        do i = 1, M
            F(i,j) = sum(PHI(i,:) * lambda**(j-1))
        end do
    end do

    tol = M * epsilon(1.0_wp)

    ! workspace query
    call SGEDMDQ('N', 'V', 'R', 'N', 'N', 'N', 1, M, N, F, M, X, N, Y, N, &
                 -1, tol, K, REIG, IMEIG, Z, M, RES, B, N, V, N-1, S, N-1, &
                 wquery, -1, iquery, -1, INFO)
    if (INFO /= 0) then
        print *, "SGEDMDQ workspace query failed, INFO =", INFO
        stop 1
    end if
    LWORK = int(wquery(2))
    LIWORK = iquery(1)
    allocate(WORK(LWORK), IWORK(LIWORK))

    call SGEDMDQ('N', 'V', 'R', 'N', 'N', 'N', 1, M, N, F, M, X, N, Y, N, &
                 -1, tol, K, REIG, IMEIG, Z, M, RES, B, N, V, N-1, S, N-1, &
                 WORK, LWORK, IWORK, LIWORK, INFO)
    if (INFO /= 0) then
        print *, "SGEDMDQ failed, INFO =", INFO
        stop 1
    end if

    if (K /= R) then
        print *, "SGEDMDQ returned unexpected rank, K =", K
        stop 1
    end if

    ! the eigenvalue order is not specified: sort descending
    do i = 1, K - 1
        imax = i - 1 + maxloc(REIG(i:K), 1)
        tmp = REIG(i);  REIG(i)  = REIG(imax);  REIG(imax)  = tmp
        tmp = IMEIG(i); IMEIG(i) = IMEIG(imax); IMEIG(imax) = tmp
        tmp = RES(i);   RES(i)   = RES(imax);   RES(imax)   = tmp
    end do

    print *, "DMD eigenvalues:"
    do i = 1, K
        print '(A,I1,A,F12.6,A,F12.6,A)', &
            "  lambda(", i, ") = ", REIG(i), "  (expected: ", lambda(i), ")"
    end do

    max_error = max(maxval(abs(REIG(1:K) - lambda)), maxval(abs(IMEIG(1:K))))
    max_residual = maxval(RES(1:K))
    print '(A,ES10.2)', "max error: ", max_error
    print '(A,ES10.2)', "max residual: ", max_residual
    if (max_error > 1e-4_wp) stop 1
    if (max_residual > 1e-4_wp) stop 1

end program main
