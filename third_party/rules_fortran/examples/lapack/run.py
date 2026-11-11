#!/usr/bin/env python3
"""Driver script to run LAPACK tests with input redirection."""
import os
import sys
import subprocess
import re

binary = sys.argv[1]
input_file = sys.argv[2]
output_file = sys.argv[3] if len(sys.argv) > 3 else None

# Windows: Bazel 7.x uses 'external/' prefix, Bazel 8.x uses relative paths
if os.name == 'nt':
    binary = os.path.normpath(binary.replace('external/', '../', 1))
    input_file = os.path.normpath(input_file.replace('external/', '../', 1))

# Run test with input file redirection
with open(input_file, 'r') as f_in:
    result = subprocess.run([binary], stdin=f_in, capture_output=True, text=True)

# Combine stdout and stderr
output = result.stdout + result.stderr

# Print test output
print(output)

# Save to output file if specified
if output_file:
    with open(output_file, 'w') as f_out:
        f_out.write(output)

# Parse results to determine pass/fail
# Look for "tests run" and "out of" patterns
tests_run = 0
tests_failed = 0
has_illegal = False
has_info_error = False

for line in output.split('\n'):
    # Count tests run: matches like "12345 tests run)"
    if 'run)' in line:
        match = re.search(r'(\d+)\s+tests?\s+run\)', line)
        if match:
            tests_run += int(match.group(1))
    # Count failures: matches like "3 out of"
    if 'out of' in line:
        match = re.search(r'(\d+)\s+out\s+of', line)
        if match:
            tests_failed += int(match.group(1))
    # Check for illegal operations
    if 'illegal' in line.lower():
        has_illegal = True
    # Check for INFO errors
    if ' INFO' in line:
        has_info_error = True

# Print summary
print("\n--- Summary ---")
print(f"Tests run: {tests_run}")
print(f"Tests failed: {tests_failed}")

# Return non-zero exit code if any failures
if tests_failed > 0 or has_illegal or has_info_error:
    if has_illegal:
        print("ERROR: Illegal operation detected")
    if has_info_error:
        print("ERROR: INFO error detected")
    sys.exit(1)
