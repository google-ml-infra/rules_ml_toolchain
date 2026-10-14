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

program hello_world_test
  use iso_fortran_env, only: int32, real64, compiler_version
  implicit none

  integer(int32), allocatable :: arr(:)
  real(real64) :: a(2, 2), b(2, 2), c(2, 2)
  character(len=64) :: buf
  integer(int32) :: i

  allocate(arr(5))
  do i = 1, 5
    arr(i) = i * 2
  end do

  if (sum(arr) /= 30) then
    stop 1
  end if
  deallocate(arr)

  a = reshape([1.0_real64, 2.0_real64, 3.0_real64, 4.0_real64], [2, 2])
  b = reshape([2.0_real64, 0.0_real64, 1.0_real64, 2.0_real64], [2, 2])
  c = matmul(a, b)

  if (abs(c(1, 1) - 2.0_real64) > 1.0e-12_real64) stop 2
  if (abs(c(2, 1) - 4.0_real64) > 1.0e-12_real64) stop 3
  if (abs(c(1, 2) - 7.0_real64) > 1.0e-12_real64) stop 4
  if (abs(c(2, 2) - 10.0_real64) > 1.0e-12_real64) stop 5

  write(buf, '(A,I0)') "Answer=", 42
  if (trim(buf) /= "Answer=42") stop 6

  if (len_trim(compiler_version()) == 0) stop 7
end program hello_world_test
