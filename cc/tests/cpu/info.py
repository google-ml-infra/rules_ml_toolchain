import sys
import os

print(f"\n--- PYTHON DEBUG INFO ---")
print(f"Executable: {sys.executable}")
print(f"Version: {sys.version}")
print(f"Prefix: {sys.prefix}")
print(f"PYTHONPATH: {os.environ.get('PYTHONPATH')}")
print(f"---------------------\n")