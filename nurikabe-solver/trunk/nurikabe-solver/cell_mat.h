#ifndef NK_SOLVE__VERDICT_MAT_H
#define NK_SOLVE__VERDICT_MAT_H

#include <glib.h>

enum NK_SOLVE_VERDICT
{
    NK_SOLVE_VERDICT__UNKNOWN,
    NK_SOLVE_VERDICT__WHITE,
    NK_SOLVE_VERDICT__BLACK,
};

typedef enum 
{
    NK_SOLVE_ERROR__SUCCESS = 0,
    NK_SOLVE_ERROR__ALLOC_FAILED,
    NK_SOLVE_ERROR__X_OUT_OF_BOUNDS,
    NK_SOLVE_ERROR__Y_OUT_OF_BOUNDS
} NK_SOLVE_ERROR_CODE;

typedef enum NK_SOLVE_VERDICT nk_solve_verdict_t;

typedef struct
{
    gint width;
    gint height;
    gchar * buf;
} nk_solve_verdict_matrix_t;

extern NK_SOLVE_ERROR_CODE
nk_solve_verdict_matrix_create(
        gint height,
        gint width,
        nk_solve_verdict_matrix_t * * result
        );

extern NK_SOLVE_ERROR_CODE
nk_solve_verdict_matrix_set(
    nk_solve_verdict_matrix_t * board,
    gint y,
    gint x,
    nk_solve_verdict_t value
    );

extern NK_SOLVE_ERROR_CODE
nk_solve_verdict_matrix_get(
    nk_solve_verdict_matrix_t * board,
    gint y,
    gint x,
    nk_solve_verdict_t * value
    );

#endif /* #ifndef NK_SOLVE__VERDICT_MAT_H */

