from .nested_wrapped_pybind import nested_pybind_func
from ..pybind_wrapped.sub._sub_private import _sub_private_private_func

def call_nested_pyind_func(x):
  return nested_pybind_func(x)

def sub_sub_private_func(x):
  return _sub_private_private_func(x)