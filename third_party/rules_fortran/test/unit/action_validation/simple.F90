module simple_preprocessed_mod
    implicit none
#ifdef USE_MPI
    integer :: mpi_enabled = 1
#endif
end module
