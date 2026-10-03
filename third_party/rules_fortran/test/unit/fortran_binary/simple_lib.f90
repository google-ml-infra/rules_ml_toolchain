module simple_lib
    implicit none
contains
    subroutine greet()
        print *, "Hello from library"
    end subroutine
end module
