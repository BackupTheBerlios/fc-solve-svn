#include "verdict_mat.h"

NK_SOLVE_ERROR_CODE
nk_solve_verdict_matrix_create(
        gint height,
        gint width,
        nk_solve_verdict_matrix_t * * result
        )
{
    nk_solve_verdict_matrix_t * ret;

    *result = NULL;

    ret = g_new(nk_solve_verdict_matrix_t, 1);

    if (! ret)
    {
        return NK_SOLVE_ERROR__ALLOC_FAILED;
    }

    ret->width = width;
    ret->height = height;

    ret->buf = g_malloc0((width*height)>>2);
    if (! ret->buf)
    {
        g_free(ret);

        return NK_SOLVE_ERROR__ALLOC_FAILED;
    }

    *result = ret;

    return NK_SOLVE_ERROR__SUCCESS;
}

NK_SOLVE_ERROR_CODE
nk_solve_verdict_matrix_free(nk_solve_verdict_matrix_t * matrix)
{
    g_free(matrix->buf);
    matrix->buf = 0;
    g_free(matrix);

    return NK_SOLVE_ERROR__SUCCESS;
}

NK_SOLVE_ERROR_CODE
nk_solve_verdict_matrix_set(
    nk_solve_verdict_matrix_t * board,
    gint y,
    gint x,
    nk_solve_verdict_t value
    )
{
    if ( ! ((y >= 0) && (y < board->height)) )
    {
        return NK_SOLVE_ERROR__Y_OUT_OF_BOUNDS;
    }

    return NK_SOLVE_ERROR__ALLOC_FAILED;
}

