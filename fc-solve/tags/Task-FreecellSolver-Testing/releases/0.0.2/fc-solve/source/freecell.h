/* Copyright (c) 2009 Shlomi Fish
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
/*
 * freecell.h - header file of the Freecell move functions
 * ("solve-for-state"/"sfs").
 *
 */

#ifndef FC_SOLVE__FREECELL_H
#define FC_SOLVE__FREECELL_H

#ifdef __cplusplus
extern "C" {
#endif

#include "config.h"
/* For fcs_state_keyval_pair_t */
#include "state.h"
/* For fc_solve_soft_thread_t and fcs_derived_states_list_t */
#include "instance.h"


DECLARE_MOVE_FUNCTION(fc_solve_sfs_move_top_stack_cards_to_founds);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_move_freecell_cards_to_founds);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_move_freecell_cards_on_top_of_stacks);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_move_non_top_stack_cards_to_founds);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_move_stack_cards_to_a_parent_on_the_same_stack);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_move_stack_cards_to_different_stacks);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_move_sequences_to_free_stacks);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_move_freecell_cards_to_empty_stack);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_move_cards_to_a_different_parent);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_empty_stack_into_freecells);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_atomic_move_card_to_empty_stack);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_atomic_move_card_to_parent);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_atomic_move_card_to_freecell);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_atomic_move_freecell_card_to_parent);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_atomic_move_freecell_card_to_empty_stack);

enum PRUNE_RET
{
    PRUNE_RET_NOT_FOUND,
    PRUNE_RET_FOLLOW_STATE
};

extern int fc_solve_sfs_raymond_prune(
    fc_solve_soft_thread_t * soft_thread,
    fcs_pass_state_t * raw_ptr_state_raw,
    fcs_collectible_state_t * * ptr_ptr_next_state
);

DECLARE_MOVE_FUNCTION(fc_solve_sfs_yukon_do_nothing);

#if 0
extern void fc_solve_sfs_yukon_move_card_to_parent(
        fc_solve_soft_thread_t * soft_thread,
        fcs_state_keyval_pair_t * ptr_state,
        fcs_derived_states_list_t * derived_states_list
        );

extern void fc_solve_sfs_yukon_move_kings_to_empty_stack(
        fc_solve_soft_thread_t * soft_thread,
        fcs_state_keyval_pair_t * ptr_state,
        fcs_derived_states_list_t * derived_states_list
        );
#endif

#ifdef __cplusplus
}
#endif

#endif /* FC_SOLVE__FREECELL_H */

