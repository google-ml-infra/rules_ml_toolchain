#!/usr/bin/env python3
"""
LAPACK Testing Summary Script

Runs all LAPACK tests and produces a summary in the same format as
the original netlib lapack_testing.py script.

Usage (via Bazel):
    bazel run //lapack:lapack_testing
    bazel run //lapack:lapack_testing -- -p s          # Single precision only
    bazel run //lapack:lapack_testing -- -t lin        # LIN tests only
    bazel run //lapack:lapack_testing -- -s            # Short summary only
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path


def parse_manifest(manifest_path):
    """Parse a Bazel runfiles MANIFEST file into a dict."""
    mapping = {}
    try:
        with open(manifest_path, 'r') as f:
            for line in f:
                line = line.strip()
                if ' ' in line:
                    runfiles_path, actual_path = line.split(' ', 1)
                    mapping[runfiles_path] = actual_path
    except Exception:
        pass
    return mapping


def find_runfiles():
    """Find the runfiles directory and manifest for Bazel."""
    # Use __file__ without resolving symlinks to stay in runfiles tree
    script_path = Path(__file__)

    # Look for .runfiles directory in parents (Linux/macOS)
    for parent in script_path.parents:
        if parent.name.endswith('.runfiles'):
            return parent, {}

    # Check environment variable
    if 'RUNFILES_DIR' in os.environ:
        runfiles = Path(os.environ['RUNFILES_DIR'])
        manifest = runfiles / 'MANIFEST'
        if manifest.exists():
            return runfiles, parse_manifest(manifest)
        return runfiles, {}

    # Check for runfiles manifest (Windows)
    if 'RUNFILES_MANIFEST_FILE' in os.environ:
        manifest = Path(os.environ['RUNFILES_MANIFEST_FILE'])
        return manifest.parent, parse_manifest(manifest)

    # Windows fallback: look for sibling .runfiles directory
    script_resolved = Path(__file__).resolve()
    for parent in script_resolved.parents:
        # Try .exe.runfiles (Windows)
        for suffix in ['.exe.runfiles', '.runfiles']:
            runfiles = parent / (parent.stem + suffix)
            if runfiles.exists():
                manifest = runfiles / 'MANIFEST'
                if manifest.exists():
                    return runfiles, parse_manifest(manifest)
                return runfiles, {}

    return None, {}


def get_binary_path(runfiles, manifest, name):
    """Get path to a LAPACK test binary."""
    # Windows: check manifest first
    if manifest:
        for key in [f"+_repo_rules+lapack/{name}", f"+_repo_rules+lapack/{name}.exe"]:
            if key in manifest:
                return manifest[key]

    # Linux/macOS: check directory structure
    candidates = [
        runfiles / "+_repo_rules+lapack" / name,
        runfiles / "+_repo_rules+lapack" / (name + ".exe"),
        runfiles / "_main" / "external" / "+_repo_rules+lapack" / name,
        runfiles / "_main" / "external" / "+_repo_rules+lapack" / (name + ".exe"),
    ]
    for p in candidates:
        if p.exists():
            return str(p)
    return None


def get_input_path(runfiles, manifest, name):
    """Get path to a LAPACK test input file."""
    # Windows: check manifest first
    if manifest:
        key = f"+_repo_rules+lapack/TESTING/{name}.in"
        if key in manifest:
            return manifest[key]

    # Linux/macOS: check directory structure
    candidates = [
        runfiles / "+_repo_rules+lapack" / "TESTING" / (name + ".in"),
        runfiles / "_main" / "external" / "+_repo_rules+lapack" / "TESTING" / (name + ".in"),
    ]
    for p in candidates:
        if p.exists():
            return str(p)
    return None


def run_test(binary, input_file, short=False):
    """Run a LAPACK test binary with input file redirection."""
    nb_test_run = 0
    nb_test_fail = 0
    nb_test_illegal = 0
    nb_test_info = 0

    if not binary or not os.path.exists(binary):
        return [0, 0, 0, 0, f"Binary not found"]
    if not input_file or not os.path.exists(input_file):
        return [0, 0, 0, 0, f"Input file not found"]

    try:
        with open(input_file, 'r') as f_in:
            result = subprocess.run(
                [binary],
                stdin=f_in,
                capture_output=True,
                text=True,
                timeout=600
            )
        output = result.stdout + result.stderr
    except subprocess.TimeoutExpired:
        return [0, 0, 0, 1, "Timeout"]
    except Exception as e:
        return [0, 0, 0, 1, str(e)]

    for line in output.split('\n'):
        words = line.split()
        # Count tests run
        if 'run)' in line:
            try:
                idx = words.index('run)')
                nb_test_run += int(words[idx - 2])
            except (ValueError, IndexError):
                pass
        # Count failures
        if 'out of' in line:
            try:
                idx = words.index('out')
                nb_test_fail += int(words[idx - 1])
            except (ValueError, IndexError):
                pass
        # Check for illegal operations
        if 'illegal' in line.lower():
            nb_test_illegal += 1
        # Check for INFO errors
        if ' INFO' in line and 'INFO=' in line:
            nb_test_info += 1

    return [nb_test_run, nb_test_fail, nb_test_illegal, nb_test_info, None]


def main():
    parser = argparse.ArgumentParser(description='LAPACK Testing Summary')
    parser.add_argument('-p', '--prec', default='x',
                        help='Precision: s/d/c/z/sd/cz/x(all)')
    parser.add_argument('-t', '--test', default='all',
                        help='Test type: lin/eig/mixed/rfp/dmd/all')
    parser.add_argument('-s', '--short', action='store_true',
                        help='Short summary only')
    args = parser.parse_args()

    runfiles, manifest = find_runfiles()
    if not runfiles:
        print("Error: Cannot find runfiles directory")
        print("Please run via: bazel run //lapack:lapack_testing")
        sys.exit(1)

    # Precision mapping
    dtypes = ['s', 'd', 'c', 'z']
    dtype_names = ['REAL', 'DOUBLE PRECISION', 'COMPLEX', 'COMPLEX16']

    if args.prec == 's':
        range_prec = [0]
    elif args.prec == 'd':
        range_prec = [1]
    elif args.prec == 'sd':
        range_prec = [0, 1]
    elif args.prec == 'c':
        range_prec = [2]
    elif args.prec == 'z':
        range_prec = [3]
    elif args.prec == 'cz':
        range_prec = [2, 3]
    else:
        range_prec = [0, 1, 2, 3]

    # Test definitions: (input_template, test_name, binary_template, test_type)
    all_tests = [
        # EIG tests (0-15)
        ('nep', 'Nonsymmetric-Eigenvalue-Problem', 'xeigtst{p}', 'eig'),
        ('sep', 'Symmetric-Eigenvalue-Problem', 'xeigtst{p}', 'eig'),
        ('se2', 'Symmetric-Eigenvalue-Problem-2-stage', 'xeigtst{p}', 'eig'),
        ('svd', 'Singular-Value-Decomposition', 'xeigtst{p}', 'eig'),
        ('{p}ec', 'Eigen-Condition', 'xeigtst{p}', 'eig'),
        ('{p}ed', 'Nonsymmetric-Eigenvalue', 'xeigtst{p}', 'eig'),
        ('{p}gg', 'Nonsymmetric-Generalized-Eigenvalue-Problem', 'xeigtst{p}', 'eig'),
        ('{p}gd', 'Nonsymmetric-Generalized-Eigenvalue-Problem-driver', 'xeigtst{p}', 'eig'),
        ('{p}sb', 'Symmetric-Eigenvalue-Problem', 'xeigtst{p}', 'eig'),
        ('{p}sg', 'Symmetric-Eigenvalue-Generalized-Problem', 'xeigtst{p}', 'eig'),
        ('{p}bb', 'Banded-Singular-Value-Decomposition-routines', 'xeigtst{p}', 'eig'),
        ('glm', 'Generalized-Linear-Regression-Model-routines', 'xeigtst{p}', 'eig'),
        ('gqr', 'Generalized-QR-and-RQ-factorization-routines', 'xeigtst{p}', 'eig'),
        ('gsv', 'Generalized-Singular-Value-Decomposition-routines', 'xeigtst{p}', 'eig'),
        ('csd', 'CS-Decomposition-routines', 'xeigtst{p}', 'eig'),
        ('lse', 'Constrained-Linear-Least-Squares-routines', 'xeigtst{p}', 'eig'),
        # LIN test (16)
        ('{p}test', 'Linear-Equation-routines', 'xlintst{p}', 'lin'),
        # Mixed precision (17)
        ('{p}{prev}test', 'Mixed-Precision-linear-equation-routines', 'xlintst{p}{prev}', 'mixed'),
        # RFP test (18)
        ('{p}test_rfp', 'RFP-linear-equation-routines', 'xlintstrf{p}', 'rfp'),
        # DMD test (19)
        ('{p}dmd', 'Dynamic-Mode-Decomposition', 'xdmdeigtst{p}', 'dmd'),
    ]

    # Filter tests based on -t option
    if args.test == 'lin':
        tests_to_run = [(i, t) for i, t in enumerate(all_tests) if t[3] == 'lin']
    elif args.test == 'eig':
        tests_to_run = [(i, t) for i, t in enumerate(all_tests) if t[3] == 'eig']
    elif args.test == 'mixed':
        tests_to_run = [(i, t) for i, t in enumerate(all_tests) if t[3] == 'mixed']
        range_prec = [1, 3]  # Only d and z have mixed precision
    elif args.test == 'rfp':
        tests_to_run = [(i, t) for i, t in enumerate(all_tests) if t[3] == 'rfp']
    elif args.test == 'dmd':
        tests_to_run = [(i, t) for i, t in enumerate(all_tests) if t[3] == 'dmd']
    else:
        tests_to_run = list(enumerate(all_tests))

    # Results storage
    results = {
        'run': [0, 0, 0, 0],
        'fail': [0, 0, 0, 0],
        'illegal': [0, 0, 0, 0],
        'info': [0, 0, 0, 0],
    }

    print()
    print("---------------- Testing LAPACK Routines ----------------")
    print()

    for prec_idx in range_prec:
        p = dtypes[prec_idx]
        name = dtype_names[prec_idx]
        prev = dtypes[prec_idx - 1] if prec_idx > 0 else ''

        if not args.short:
            print()
            print(f"------------------------- {name} ------------------------")
            print()
            sys.stdout.flush()

        for test_idx, (input_template, test_name, binary_template, test_type) in tests_to_run:
            # Skip mixed precision for s and c
            if test_type == 'mixed' and p in ['s', 'c']:
                continue

            # Format input and binary names
            input_name = input_template.format(p=p, prev=prev)
            binary_name = binary_template.format(p=p, prev=prev)

            # Get paths
            binary_path = get_binary_path(runfiles, manifest, binary_name)
            input_path = get_input_path(runfiles, manifest, input_name)

            if not binary_path or not input_path:
                if not args.short:
                    print(f"Skipping {name} {test_name} (not available)")
                continue

            output_name = f"{p}{input_name.replace(p, '', 1)}" if input_name.startswith(p) else f"{p}{input_name}"

            if not args.short:
                print(f"Testing {name} {test_name}-{output_name}.out ", end='')
                sys.stdout.flush()

            # Run test
            nb_test = run_test(binary_path, input_path, args.short)

            # Accumulate results
            results['run'][prec_idx] += nb_test[0]
            results['fail'][prec_idx] += nb_test[1]
            results['illegal'][prec_idx] += nb_test[2]
            results['info'][prec_idx] += nb_test[3]

            if not args.short:
                if nb_test[4]:  # Error message
                    print(f"ERROR: {nb_test[4]}")
                elif nb_test[0] > 0:
                    print(f"passed: {nb_test[0]}")
                    if nb_test[1] > 0:
                        print(f"failing to pass the threshold: {nb_test[1]}")
                    if nb_test[2] > 0:
                        print(f"Illegal Error: {nb_test[2]}")
                    if nb_test[3] > 0:
                        print(f"Info Error: {nb_test[3]}")
                else:
                    print("completed")
                print()

            sys.stdout.flush()

    # Print summary
    print()
    print("\t\t\t-->   LAPACK TESTING SUMMARY  <--")
    print("\t\tProcessing LAPACK Testing output")
    print("SUMMARY             \tnb test run \tnumerical error   \tother error  ")
    print("================   \t===========\t=================\t================  ")

    total_run = 0
    total_fail = 0
    total_other = 0

    for prec_idx in range_prec:
        name = dtype_names[prec_idx]
        run = results['run'][prec_idx]
        fail = results['fail'][prec_idx]
        other = results['illegal'][prec_idx] + results['info'][prec_idx]

        total_run += run
        total_fail += fail
        total_other += other

        fail_pct = (fail / run * 100) if run > 0 else 0
        other_pct = (other / run * 100) if run > 0 else 0

        print(f"{name:20}\t{run}\t\t{fail}\t({fail_pct:.3f}%)\t{other}\t({other_pct:.3f}%)\t")

    print()
    total_fail_pct = (total_fail / total_run * 100) if total_run > 0 else 0
    total_other_pct = (total_other / total_run * 100) if total_run > 0 else 0
    print(f"--> ALL PRECISIONS\t{total_run}\t\t{total_fail}\t({total_fail_pct:.3f}%)\t{total_other}\t({total_other_pct:.3f}%)\t")
    print()


if __name__ == '__main__':
    main()
