module simple_mod
    implicit none
contains
    function add(a, b) result(c)
        real :: a, b, c
        c = a + b
    end function
end module
