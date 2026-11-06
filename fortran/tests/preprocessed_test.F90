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

program preprocessed_test
  use math_mod, only: add_ints
  implicit none
  integer :: val

#ifdef EXPECTED_ANSWER
  val = add_ints(20, 22)
  if (val /= EXPECTED_ANSWER) stop 1
#else
  stop 2
#endif
end program preprocessed_test
