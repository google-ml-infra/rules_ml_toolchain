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

program fortran_calls_c_test
  use iso_c_binding, only: c_int
  implicit none

  interface
    function cpp_scale_and_add(x, scale, offset) bind(c, name="cpp_scale_and_add") result(res)
      import :: c_int
      implicit none
      integer(c_int), value, intent(in) :: x, scale, offset
      integer(c_int) :: res
    end function cpp_scale_and_add
  end interface

  integer(c_int) :: res
  res = cpp_scale_and_add(10, 4, 2)
  if (res /= 42) stop 1
end program fortran_calls_c_test
