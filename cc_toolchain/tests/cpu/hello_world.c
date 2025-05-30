/* Copyright 2025 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
============================================================================== */

#include <stdio.h>

int main() {
  //test();
  printf("Hello C world!\n");

  FILE *fp;
  char *filename = "/tmp/hello_world.txt";

  fp = fopen(filename, "w");

  if (fp == NULL) {
    printf("Could not open file %s\n", filename);
    return 1;
  }

  fprintf(fp, "Hello C world!\n");
  fclose(fp);

  return 0;
}
