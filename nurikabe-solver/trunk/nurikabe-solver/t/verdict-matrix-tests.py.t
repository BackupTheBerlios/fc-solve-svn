#!/usr/bin/env python
from TAP.Simple import *
from ctypes import *

plan(3)

NK_SOLVE_ERROR__SUCCESS = 0
NK_SOLVE_ERRRO__ALLOC_FAILED = 1
NK_SOLVE_ERROR__X_OUT_OF_BOUNDS = 2
NK_SOLVE_ERROR__Y_OUT_OF_BOUNDS = 3

nk_solve = CDLL("./libnk-solve.so")

verdict_mat_create = nk_solve.nk_solve_verdict_matrix_create
verdict_mat_free = nk_solve.nk_solve_verdict_matrix_free

class Mat:
    def __init__(self):
        self.matrix = c_void_p()
    
    def create(self, y, x):
        return nk_solve.nk_solve_verdict_matrix_create(
                c_int(y), c_int(x), byref(self.matrix)
                )

    def free(self):
        return nk_solve.nk_solve_verdict_matrix_free(self.matrix)

def test1():
    m = Mat()
    # TEST
    eq_ok (
            m.create(10, 5), 
            NK_SOLVE_ERROR__SUCCESS, 
            "nk_solve_verdict_matrix_create correct error value"
            )

    # TEST
    ok (m.matrix, "matrix is allocated")

    # TEST
    eq_ok (
            m.free(),
            NK_SOLVE_ERROR__SUCCESS,
            "nk_solve_verdict_matrix_free was successful"
            )

test1();
