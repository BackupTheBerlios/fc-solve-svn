/*
    config.h - Configuration file for Freecell Solver

    Written by Shlomi Fish, 2000

    This file is distributed under the public domain.
    (It is not copyrighted).
*/

#ifndef FC_SOLVE__CONFIG_H
#define FC_SOLVE__CONFIG_H

#ifdef __cplusplus
extern "C" {
#endif

#cmakedefine DEBUG_STATES
#cmakedefine COMPACT_STATES
#cmakedefine INDIRECT_STACK_STATES

#undef CARD_DEBUG_PRES

/*
 * Define this macro if the C compiler supports the keyword inline or
 * a similar keyword that was found by Autoconf (and defined as inline).
 * */
#undef HAVE_C_INLINE


/*
    The sort margin size for the previous states array.
*/
#define PREV_STATES_SORT_MARGIN 32
/*
    The amount prev_states grow by each time it each resized.
    Should be greater than 0 and in order for the program to be
    efficient, should be much bigger than
    PREV_STATES_SORT_MARGIN.
*/
#define PREV_STATES_GROW_BY 128

/*
    The amount the pack pointers array grows by. Shouldn't be too high
    because it doesn't happen too often.
*/
#define IA_STATE_PACKS_GROW_BY 32

/*
 * The maximal number of Freecells. For efficiency's sake it should be a
 * multiple of 4.
 * */

#define MAX_NUM_FREECELLS 4

/*
 * The maximal number of Stacks. For efficiency's sake it should be a
 * multiple of 4.
 * */

#define MAX_NUM_STACKS 10
/*
 * The maximal number of initial cards that can be found in a stack.
 * */
#define MAX_NUM_INITIAL_CARDS_IN_A_STACK 8

#define MAX_NUM_DECKS 2


#define FCS_STATE_STORAGE_INDIRECT 0
#define FCS_STATE_STORAGE_INTERNAL_HASH 1
#define FCS_STATE_STORAGE_LIBAVL_AVL_TREE 2
#define FCS_STATE_STORAGE_LIBAVL_REDBLACK_TREE 3
#define FCS_STATE_STORAGE_LIBREDBLACK_TREE 4
#define FCS_STATE_STORAGE_GLIB_TREE 5
#define FCS_STATE_STORAGE_GLIB_HASH 6
#define FCS_STATE_STORAGE_DB_FILE 7

#define FCS_STACK_STORAGE_INTERNAL_HASH 0
#define FCS_STACK_STORAGE_LIBAVL_AVL_TREE 1
#define FCS_STACK_STORAGE_LIBAVL_REDBLACK_TREE 2
#define FCS_STACK_STORAGE_LIBREDBLACK_TREE 3
#define FCS_STACK_STORAGE_GLIB_TREE 4
#define FCS_STACK_STORAGE_GLIB_HASH 5

#undef FCS_STATE_STORAGE
#undef FCS_STACK_STORAGE

#ifdef __cplusplus
}
#endif

#endif

/* Define to 1 if you have the `avl' library (-lavl). */
#undef HAVE_LIBAVL

/* Define to 1 if you have the `glib' library (-lglib). */
#undef HAVE_LIBGLIB

/* Define to 1 if you have the `m' library (-lm). */
#undef HAVE_LIBM

/* Define to 1 if you have the `redblack' library (-lredblack). */
#undef HAVE_LIBREDBLACK

/* Define to 1 if you have the <limits.h> header file. */
#undef HAVE_LIMITS_H

/* Define to 1 if you have the <memory.h> header file. */
#undef HAVE_MEMORY_H

/* Define to 1 if you have the <stdint.h> header file. */
#undef HAVE_STDINT_H

/* Define to 1 if you have the <stdlib.h> header file. */
#undef HAVE_STDLIB_H

/* Define to 1 if you have the `strdup' function. */
#undef HAVE_STRDUP

/* Define to 1 if you have the <strings.h> header file. */
#undef HAVE_STRINGS_H

/* Define to 1 if you have the <string.h> header file. */
#undef HAVE_STRING_H

/* Define to 1 if you have the <sys/stat.h> header file. */
#undef HAVE_SYS_STAT_H

/* Define to 1 if you have the <sys/types.h> header file. */
#undef HAVE_SYS_TYPES_H

/* Define to 1 if you have the <unistd.h> header file. */
#undef HAVE_UNISTD_H

/* Name of package */
#undef PACKAGE

/* Define to the address where bug reports for this package should be sent. */
#undef PACKAGE_BUGREPORT

/* Define to the full name of this package. */
#undef PACKAGE_NAME

/* Define to the full name and version of this package. */
#undef PACKAGE_STRING

/* Define to the one symbol short name of this package. */
#undef PACKAGE_TARNAME

/* Define to the version of this package. */
#undef PACKAGE_VERSION

/* Define as the return type of signal handlers (`int' or `void'). */
#undef RETSIGTYPE

/* Define to 1 if you have the ANSI C header files. */
#undef STDC_HEADERS

/* Version number of package */
#undef VERSION

/* Define to empty if `const' does not conform to ANSI C. */
#undef const

/* Define to `__inline__' or `__inline' if that's what the C compiler
   calls it, or to nothing if 'inline' is not supported under any name.  */
#ifndef __cplusplus
#undef inline
#endif

/* Define to `unsigned int' if <sys/types.h> does not define. */
#undef size_t
