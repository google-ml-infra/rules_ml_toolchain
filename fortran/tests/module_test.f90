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

program module_test
  use iso_c_binding, only: c_int, c_double
  use math_mod, only: add_ints, dot_product_f64
  use linalg_mod, only: sum_of_squares
  implicit none

  integer(c_int) :: vec(4)
  real(c_double) :: x(3), y(3), dp

  if (add_ints(19, 23) /= 42) stop 1

  vec = [1, 2, 3, 4]
  if (sum_of_squares(vec) /= 30) stop 2

  x = [1.0_c_double, 2.0_c_double, 3.0_c_double]
  y = [4.0_c_double, 5.0_c_double, 6.0_c_double]
  dp = dot_product_f64(3, x, y)
  if (abs(dp - 32.0_c_double) > 1.0e-12_c_double) stop 3
end program module_test
