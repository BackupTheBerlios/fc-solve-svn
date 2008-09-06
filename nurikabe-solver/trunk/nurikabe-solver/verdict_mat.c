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

