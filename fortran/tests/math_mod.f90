! Copyright 2026 Google LLC
!
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!     https://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.
! ==============================================================================

module math_mod
  use iso_c_binding, only: c_int, c_float, c_double
  implicit none
  private
  public :: add_ints, dot_product_f64, saxpy_f32, square_array

contains

  pure function add_ints(a, b) bind(c, name="fortran_add_ints") result(res)
    integer(c_int), value, intent(in) :: a, b
    integer(c_int) :: res
    res = a + b
  end function add_ints

  pure function dot_product_f64(n, x, y) bind(c, name="fortran_dot_product") result(res)
    integer(c_int), value, intent(in) :: n
    real(c_double), intent(in) :: x(n), y(n)
    real(c_double) :: res
    res = dot_product(x, y)
  end function dot_product_f64

  subroutine saxpy_f32(n, alpha, x, y) bind(c, name="fortran_saxpy")
    integer(c_int), value, intent(in) :: n
    real(c_float), value, intent(in) :: alpha
    real(c_float), intent(in) :: x(n)
    real(c_float), intent(inout) :: y(n)
    y = alpha * x + y
  end subroutine saxpy_f32

  pure function square_array(x) result(res)
    integer(c_int), intent(in) :: x(:)
    integer(c_int) :: res(size(x))
    res = x * x
  end function square_array

end module math_mod
