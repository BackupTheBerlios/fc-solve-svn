#!/usr/bin/env python
from TAP.Simple import *
from ctypes import *

plan(2)

NK_SOLVE_ERROR__SUCCESS = 0
NK_SOLVE_ERRRO__ALLOC_FAILED = 1
NK_SOLVE_ERROR__X_OUT_OF_BOUNDS = 2
NK_SOLVE_ERROR__Y_OUT_OF_BOUNDS = 3

nk_solve = CDLL("./libnk-solve.so")

verdict_mat_create = nk_solve.nk_solve_verdict_matrix_create

matrix = c_void_p()
ret = verdict_mat_create(5, 10, byref(matrix))


# TEST
eq_ok (ret, NK_SOLVE_ERROR__SUCCESS, 
        "nk_solve_verdict_matrix_create correct error value"
        )

# TEST
ok(matrix, "matrix is allocated")

