module fortran_cc_interop
    implicit none
contains
    subroutine fortran_wrapper()
        print *, "Fortran module with C dep"
    end subroutine
end module
