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

module linalg_mod
  use iso_c_binding, only: c_int
  use math_mod, only: add_ints, square_array
  implicit none
  private
  public :: sum_of_squares

contains

  pure function sum_of_squares(x) result(total)
    integer(c_int), intent(in) :: x(:)
    integer(c_int) :: sq(size(x))
    integer(c_int) :: total, i

    sq = square_array(x)
    total = 0
    do i = 1, size(sq)
      total = add_ints(total, sq(i))
    end do
  end function sum_of_squares

end module linalg_mod
