#!/usr/bin/env python3
"""driver script to run BLAS tests with input redirection."""
import os
import sys
import subprocess

binary = sys.argv[1]
input_file = sys.argv[2]

# Windows: Bazel 7.x uses 'external/' prefix, Bazel 8.x uses relative paths
if os.name == 'nt':
    binary = os.path.normpath(binary.replace('external/', '../', 1))
    input_file = os.path.normpath(input_file.replace('external/', '../', 1))

# Parse output filename from input file (first line, quoted)
with open(input_file, 'r') as f:
    first_line = f.readline()
    output_file = first_line.split("'")[1]

with open(input_file, 'r') as f:
    subprocess.run([binary], stdin=f, check=True, text=True)

# Print test results
if os.path.exists(output_file):
    with open(output_file, 'r') as f:
        print(f.read())
