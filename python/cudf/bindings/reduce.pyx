# Copyright (c) 2018, NVIDIA CORPORATION.

# cython: profile=False
# distutils: language = c++
# cython: embedsignature = True
# cython: language_level = 3

# Copyright (c) 2018, NVIDIA CORPORATION.

from .cudf_cpp cimport *
from .cudf_cpp import *

import numpy as np
import pandas as pd
import pyarrow as pa

cimport numpy as np

from librmm_cffi import librmm as rmm


from libc.stdint cimport uintptr_t
from libc.stdlib cimport calloc, malloc, free

from libcpp.map cimport map as cmap
from libcpp.string  cimport string as cstring



def apply_reduce(reduction, col):
    """
      Call gdf reductions.
    """


    outsz = gdf_reduce_optimal_output_size()
    out = rmm.device_array(outsz, dtype=col.dtype)
    cdef uintptr_t out_ptr = get_ctype_ptr(out)

    cdef gdf_column* c_col = column_view_from_column(col)

    cdef gdf_error result
    if reduction == 'max':
        with nogil:
            result = gdf_max(<gdf_column*>c_col, <void*>out_ptr, outsz)
    elif reduction == 'min':
        with nogil:
            result = gdf_min(<gdf_column*>c_col, <void*>out_ptr, outsz)
    elif reduction == 'sum':
        with nogil:
            result = gdf_sum(<gdf_column*>c_col, <void*>out_ptr, outsz)
    elif reduction == 'sum_of_squares':
        with nogil:
            result = gdf_sum_of_squares(<gdf_column*>c_col,
                                        <void*>out_ptr,
                                        outsz)

    check_gdf_error(result)

    free(c_col)


    return out[0]
