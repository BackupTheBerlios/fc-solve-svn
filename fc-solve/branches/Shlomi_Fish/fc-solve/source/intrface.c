/*
 * intrface.c - instance interface functions for Freecell Solver
 *
 * Written by Shlomi Fish (shlomif@vipe.technion.ac.il), 2000-2001
 *
 * This file is in the public domain (it's uncopyrighted).
 */

#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <stdio.h>
#include <math.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#if FCS_STATE_STORAGE==FCS_STATE_STORAGE_LIBREDBLACK_TREE
#include <search.h>
#endif

#define NUM_TIMES_STEP 50

#include "config.h"
#include "state.h"
#include "card.h"
#include "fcs_dm.h"
#include "fcs.h"

#include "fcs_isa.h"

#include "caas.h"

#include "preset.h"

#ifdef DMALLOC
#include "dmalloc.h"
#endif

/*
    General use of this interface:
    1. freecell_solver_alloc_instance()
    2. Set the parameters of the game
    3. If you wish to revert, go to step #11.
    4. freecell_solver_init_instance()
    5. Call freecell_solver_solve_instance() with the initial board.
    6. If it returns FCS_STATE_SUSPEND_PROCESS and you wish to proceed,
       then increase the iteration limit and call
       freecell_solver_resume_instance().
    7. Repeat Step #6 zero or more times.
    8. If the last call to solve_instance() or resume_instance() returned
       FCS_STATE_SUSPEND_PROCESS then call
       freecell_solver_unresume_instance().
    9. If the solving was successful you can use the move stacks or the
       intermediate stacks. (Just don't destory them in any way).
    10. Call freecell_solver_finish_instance().
    11. Call freecell_solver_free_instance().

    The library functions inside lib.c (a.k.a fcs_user()) give an
    easier approach for embedding Freecell Solver into your library. The
    intent of this comment is to document the code, rather than to be
    a guideline for the user.
*/

#if 0
static const double freecell_solver_a_star_default_weights[5] = {0.5,0,0.5,0,0};
#else
static const double freecell_solver_a_star_default_weights[5] = {0.5,0,0.3,0,0.2};
#endif







static void freecell_solver_initialize_bfs_queue(freecell_solver_soft_thread_t * soft_thread)
{
    /* Initialize the BFS queue. We have one dummy element at the beginning
       in order to make operations simpler. */
    soft_thread->bfs_queue = (fcs_states_linked_list_item_t*)malloc(sizeof(fcs_states_linked_list_item_t));
    soft_thread->bfs_queue->next = (fcs_states_linked_list_item_t*)malloc(sizeof(fcs_states_linked_list_item_t));
    soft_thread->bfs_queue_last_item = soft_thread->bfs_queue->next;
    soft_thread->bfs_queue_last_item->next = NULL;
}

static void foreach_soft_thread(
    freecell_solver_instance_t * instance,
    void (*soft_thread_callback)(
        freecell_solver_soft_thread_t * soft_thread,
        void * context
        ),
    void * context
    )

{
    int ht_idx, st_idx;
    for(ht_idx = 0 ; ht_idx<instance->num_hard_threads; ht_idx++)
    {
        for(st_idx = 0 ; st_idx < instance->hard_threads[ht_idx]->num_soft_threads; st_idx++)
        {
            soft_thread_callback(instance->hard_threads[ht_idx]->soft_threads[st_idx], context);
        }
    }

    if (instance->optimization_thread)
    {
        soft_thread_callback(instance->optimization_thread->soft_threads[0], context);
    }
}



static void soft_thread_clean_soft_dfs(
    freecell_solver_soft_thread_t * soft_thread,
    void * context
    )
{
    /* Check if a Soft-DFS-type scan was called in the first place */
    if (soft_thread->soft_dfs_derived_states_lists == NULL)
    {
        /* If not - do nothing */
        return;
    }

    /* De-allocate the Soft-DFS specific stacks */
    {
        int depth;
        for(depth=0;depth<soft_thread->num_solution_states-1;depth++)
        {
            free(soft_thread->soft_dfs_derived_states_lists[depth].states);
            free(soft_thread->soft_dfs_derived_states_random_indexes[depth]);
        }
        for(;depth<soft_thread->dfs_max_depth;depth++)
        {
            if (soft_thread->soft_dfs_derived_states_lists[depth].max_num_states)
            {
                free(soft_thread->soft_dfs_derived_states_lists[depth].states);
                free(soft_thread->soft_dfs_derived_states_random_indexes[depth]);
            }
        }

#define MYFREE(what) { free(soft_thread->what); soft_thread->what = NULL; }
        MYFREE(solution_states)
        MYFREE(soft_dfs_derived_states_lists);
        MYFREE(soft_dfs_test_indexes);
        MYFREE(soft_dfs_current_state_indexes);
        MYFREE(soft_dfs_num_freecells);
        MYFREE(soft_dfs_num_freestacks);
        MYFREE(soft_dfs_derived_states_random_indexes);
        MYFREE(soft_dfs_derived_states_random_indexes_max_size);
#undef MYFREE
    }
}

static void clean_soft_dfs(
        freecell_solver_instance_t * instance
        )
{
    foreach_soft_thread(instance, soft_thread_clean_soft_dfs, NULL);
}

static freecell_solver_soft_thread_t * alloc_soft_thread(
        freecell_solver_hard_thread_t * hard_thread
        )
{
    freecell_solver_soft_thread_t * soft_thread;
    int a;

    /* Make sure we are not exceeding the maximal number of soft threads
     * for an instance. */
    if (hard_thread->instance->next_soft_thread_id == MAX_NUM_SCANS)
    {
        return NULL;
    }

    soft_thread = malloc(sizeof(freecell_solver_soft_thread_t));

    soft_thread->hard_thread = hard_thread;

    soft_thread->id = (hard_thread->instance->next_soft_thread_id)++;

    soft_thread->dfs_max_depth = 0;

    /* Initialize all the Soft-DFS stacks to NULL */
#define SET_TO_NULL(what) soft_thread->what = NULL;
    SET_TO_NULL(solution_states);
    SET_TO_NULL(soft_dfs_derived_states_lists);
    SET_TO_NULL(soft_dfs_current_state_indexes);
    SET_TO_NULL(soft_dfs_test_indexes);
    SET_TO_NULL(soft_dfs_current_state_indexes);
    SET_TO_NULL(soft_dfs_num_freecells);
    SET_TO_NULL(soft_dfs_num_freestacks);
    SET_TO_NULL(soft_dfs_derived_states_random_indexes);
    SET_TO_NULL(soft_dfs_derived_states_random_indexes_max_size);
#undef SET_TO_NULL

    /* The default solving method */
    soft_thread->method = FCS_METHOD_SOFT_DFS;

    soft_thread->orig_method = FCS_METHOD_NONE;

    freecell_solver_initialize_bfs_queue(soft_thread);

    /* Initialize the priotity queue of the A* scan */
    soft_thread->a_star_pqueue = malloc(sizeof(PQUEUE));
    freecell_solver_PQueueInitialise(
        soft_thread->a_star_pqueue,
        1024,
        INT_MAX,
        1
        );

    /* Set the default A* weigths */
    for(a=0;a<(sizeof(soft_thread->a_star_weights)/sizeof(soft_thread->a_star_weights[0]));a++)
    {
        soft_thread->a_star_weights[a] = freecell_solver_a_star_default_weights[a];
    }

    soft_thread->rand_gen = freecell_solver_rand_alloc(24);

    soft_thread->initialized = 0;

    soft_thread->num_times_step = NUM_TIMES_STEP;

#if 0
    {
        char * no_use;
        freecell_solver_apply_tests_order(soft_thread, "[01][23456789]", &no_use);
    }
#else
    soft_thread->tests_order_num = soft_thread->hard_thread->instance->instance_tests_order_num;
    memcpy(soft_thread->tests_order, soft_thread->hard_thread->instance->instance_tests_order, sizeof(soft_thread->tests_order));
#endif

    soft_thread->is_finished = 0;

    return soft_thread;
}

static freecell_solver_hard_thread_t * alloc_hard_thread(
        freecell_solver_instance_t * instance
        )
{
    freecell_solver_hard_thread_t * hard_thread;

    /* Make sure we are not exceeding the maximal number of soft threads
     * for an instance. */
    if (instance->next_soft_thread_id == MAX_NUM_SCANS)
    {
        return NULL;
    }

    hard_thread = malloc(sizeof(freecell_solver_hard_thread_t));

    hard_thread->instance = instance;

    hard_thread->num_times = 0;

    hard_thread->num_soft_threads = 1;

    hard_thread->soft_threads =
        malloc(sizeof(hard_thread->soft_threads[0]) *
               hard_thread->num_soft_threads
        );

    hard_thread->soft_threads[0] = alloc_soft_thread(hard_thread);

    /* Set a limit on the Hard-Thread's scan. */
    hard_thread->num_times_step = NUM_TIMES_STEP;

    hard_thread->ht_max_num_times = hard_thread->num_times_step;

    hard_thread->num_soft_threads_finished = 0;

    return hard_thread;
}


/*
    This function allocates a Freecell Solver instance struct and set the
    default values in it. After the call to this function, the program can
    set parameters in it which are different from the default.

    Afterwards freecell_solver_init_instance() should be called in order
    to really prepare it for solving.
  */
freecell_solver_instance_t * freecell_solver_alloc_instance(void)
{
    freecell_solver_instance_t * instance;

    instance = malloc(sizeof(freecell_solver_instance_t));

#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_INDIRECT)
    instance->num_indirect_prev_states = 0;
    instance->max_num_indirect_prev_states = 0;
#endif

    instance->num_times = 0;

    instance->num_states_in_collection = 0;

    instance->max_num_times = -1;
    instance->max_depth = -1;
    instance->max_num_states_in_collection = -1;

#ifdef FCS_WITH_TALONS
    instance->talon_type = FCS_TALON_NONE;
#endif

    instance->num_hard_threads = 0;

    freecell_solver_apply_preset_by_name(instance, "freecell");

    /****************************************/

    instance->debug_iter_output = 0;

    instance->next_soft_thread_id = 0;

    instance->num_hard_threads = 1;

    instance->hard_threads = malloc(sizeof(instance->hard_threads[0]) * instance->num_hard_threads);

    instance->hard_threads[0] = alloc_hard_thread(instance);

    instance->solution_moves = NULL;

    instance->instance_solution_states = NULL;

    instance->proto_solution_moves = NULL;

    instance->optimize_solution_path = 0;

#ifdef FCS_WITH_MHASH
    instance->mhash_type = MHASH_MD5;
#endif

    instance->optimization_thread = NULL;

    instance->num_hard_threads_finished = 0;

    return instance;
}





static void free_bfs_queue(freecell_solver_soft_thread_t * soft_thread)
{
    /* Free the BFS linked list */
    fcs_states_linked_list_item_t * item, * next_item;
    item = soft_thread->bfs_queue;
    while (item != NULL)
    {
        next_item = item->next;
        free(item);
        item = next_item;
    }
}

static void free_instance_soft_thread_callback(freecell_solver_soft_thread_t * soft_thread, void * context)
{
    free_bfs_queue(soft_thread);
    freecell_solver_rand_free(soft_thread->rand_gen);

    freecell_solver_PQueueFree(soft_thread->a_star_pqueue);
    free(soft_thread->a_star_pqueue);
    /* The data-structure itself was allocated */
    free(soft_thread);
}


/*
    This function is the last function that should be called in the
    sequence of operations on instance, and it is meant for de-allocating
    whatever memory was allocated by alloc_instance().
  */
void freecell_solver_free_instance(freecell_solver_instance_t * instance)
{
    int ht_idx;

    foreach_soft_thread(instance, free_instance_soft_thread_callback, NULL);

    for(ht_idx=0; ht_idx < instance->num_hard_threads; ht_idx++)
    {
        free(instance->hard_threads[ht_idx]->soft_threads);
        free(instance->hard_threads[ht_idx]);
    }
    free(instance->hard_threads);
    if (instance->optimization_thread)
    {
        free(instance->optimization_thread->soft_threads);
        free(instance->optimization_thread);
    }

    free(instance);
}


static void normalize_a_star_weights(
    freecell_solver_soft_thread_t * soft_thread,
    void * context
    )
{
    /* Normalize the A* Weights, so the sum of all of them would be 1. */
    double sum;
    int a;
    sum = 0;
    for(a=0;a<(sizeof(soft_thread->a_star_weights)/sizeof(soft_thread->a_star_weights[0]));a++)
    {
        if (soft_thread->a_star_weights[a] < 0)
        {
            soft_thread->a_star_weights[a] = freecell_solver_a_star_default_weights[a];
        }
        sum += soft_thread->a_star_weights[a];
    }
    if (sum == 0)
    {
        sum = 1;
    }
    for(a=0;a<(sizeof(soft_thread->a_star_weights)/sizeof(soft_thread->a_star_weights[0]));a++)
    {
        soft_thread->a_star_weights[a] /= sum;
    }
}

static void accumulate_tests_order(
    freecell_solver_soft_thread_t * soft_thread,
    void * context
    )
{
    int * tests_order = (int *)context;
    int a;
    for(a=0;a<soft_thread->tests_order_num;a++)
    {
        *tests_order |= (1 << (soft_thread->tests_order[a] & FCS_TEST_ORDER_NO_FLAGS_MASK));
    }
}

static void determine_scan_completeness(
    freecell_solver_soft_thread_t * soft_thread,
    void * context
    )
{
    int global_tests_order = *(int *)context;
    int tests_order = 0;
    int a;
    for(a=0;a<soft_thread->tests_order_num;a++)
    {
        tests_order |= (1 << (soft_thread->tests_order[a] & FCS_TEST_ORDER_NO_FLAGS_MASK));
    }
    soft_thread->is_a_complete_scan = (tests_order == global_tests_order);
}


void freecell_solver_init_instance(freecell_solver_instance_t * instance)
{
    int ht_idx;
#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_INDIRECT)
    instance->num_prev_states_margin = 0;

    instance->max_num_indirect_prev_states = PREV_STATES_GROW_BY;

    instance->indirect_prev_states = (fcs_state_with_locations_t * *)malloc(sizeof(fcs_state_with_locations_t *) * instance->max_num_indirect_prev_states);
#endif

    /* Initialize the state packs */
    for(ht_idx=0;ht_idx<instance->num_hard_threads;ht_idx++)
    {
        instance->hard_threads[ht_idx]->num_times_left_for_soft_thread =
            instance->hard_threads[ht_idx]->soft_threads[0]->num_times_step;
        freecell_solver_state_ia_init(instance->hard_threads[ht_idx]);
    }

    /* Normalize the A* Weights, so the sum of all of them would be 1. */
    foreach_soft_thread(instance, normalize_a_star_weights, NULL);

    {
        int total_tests = 0;
        foreach_soft_thread(instance, accumulate_tests_order, &total_tests);
        foreach_soft_thread(instance, determine_scan_completeness, &total_tests);
    }


}




/* These are all stack comparison functions to be used for the stacks
   cache when using INDIRECT_STACK_STATES
*/
#if defined(INDIRECT_STACK_STATES)

extern int freecell_solver_stack_compare_for_comparison(const void * v_s1, const void * v_s2);

#if ((FCS_STACK_STORAGE != FCS_STACK_STORAGE_GLIB_TREE) && (FCS_STACK_STORAGE != FCS_STACK_STORAGE_GLIB_HASH))
static int fcs_stack_compare_for_comparison_with_context(
    const void * v_s1,
    const void * v_s2,
#if (FCS_STACK_STORAGE == FCS_STACK_STORAGE_LIBREDBLACK_TREE)
    const
#endif
    void * context

    )
{
    return freecell_solver_stack_compare_for_comparison(v_s1, v_s2);
}
#endif





#if (FCS_STACK_STORAGE == FCS_STACK_STORAGE_GLIB_HASH)
/* A hash calculation function for use in glib's hash */
static guint freecell_solver_glib_hash_stack_hash_function (
    gconstpointer key
    )
{
    guint hash_value_int;
    /* Calculate the hash value for the stack */
    /* This hash function was ripped from the Perl source code.
     * (It is not derived work however). */
    const char * s_ptr = (char*)key;
    const char * s_end = s_ptr+fcs_standalone_stack_len((fcs_card_t *)key)+1;
    hash_value_int = 0;
    while (s_ptr < s_end)
    {
        hash_value_int += (hash_value_int << 5) + *(s_ptr++);
    }
    hash_value_int += (hash_value_int >> 5);

#if 0
    MD5_CTX md5_context;
    fcs_card_t * stack;
    char hash_value[16];

    stack = (fcs_card_t * )key;

    MD5Init(&md5_context);
    MD5Update(
        &md5_context,
        key,
        fcs_standalone_stack_len(stack)+1
        );
    MD5Final(hash_value, &md5_context);

    return *(guint*)hash_value;
#endif

}





static gint freecell_solver_glib_hash_stack_compare (
    gconstpointer a,
    gconstpointer b
)
{
    return !(fcs_stack_compare_for_comparison(a,b));
}
#endif // (FCS_STACK_STORAGE == FCS_STACK_STORAGE_GLIB_HASH)





#endif // defined(INDIRECT_STACK_STATES)





#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_GLIB_HASH)
/*
 * This hash function is defined in caas.c
 *
 * */
extern guint freecell_solver_hash_function(gconstpointer key);
#endif

/*
 * This function traces the solution from the final state down
 * to the initial state
 * */
static void trace_solution(
    freecell_solver_instance_t * instance
    )
{
    /*
        Trace the solution.
    */
    int num_solution_states;
    fcs_state_with_locations_t * s1;
    int last_depth;

    s1 = instance->final_state;

    /* The depth of the last state reached is the number of them */
    num_solution_states = instance->instance_num_solution_states = s1->depth+1;

    if (instance->instance_solution_states != NULL)
    {
        free(instance->instance_solution_states);
    }
    if (instance->proto_solution_moves != NULL)
    {
        free(instance->proto_solution_moves);
    }

    /* Allocate space for the solution stacks */
    instance->instance_solution_states = malloc(sizeof(fcs_state_with_locations_t *)*num_solution_states);
    instance->proto_solution_moves = malloc(sizeof(fcs_move_stack_t *) * (num_solution_states-1));
    /* Retrace the step from the current state to its parents */
    while (s1->parent != NULL)
    {
        /* Mark the state as part of the non-optimized solution */
        s1->visited |= FCS_VISITED_IN_SOLUTION_PATH;
        /* Duplicate the move stack */
        fcs_move_stack_duplicate_into_var(
            instance->proto_solution_moves[s1->depth-1],
            s1->moves_to_parent
            );
        /* Duplicate the state to a freshly malloced memory */
        instance->instance_solution_states[s1->depth] = (fcs_state_with_locations_t*)malloc(sizeof(fcs_state_with_locations_t));
        fcs_duplicate_state(*(instance->instance_solution_states[s1->depth]), *s1);

        last_depth = s1->depth;

        /* Move to the parent state */
        s1 = s1->parent;
    }
    /* There's one more state than there are move stacks */
    s1->visited |= FCS_VISITED_IN_SOLUTION_PATH;
    instance->instance_solution_states[0] = (fcs_state_with_locations_t*)malloc(sizeof(fcs_state_with_locations_t));
    fcs_duplicate_state(*(instance->instance_solution_states[0]), *s1);
}



/*
    This function combines the move stacks of every depth to one big
    move stack.
*/
static void create_total_moves_stack(
    freecell_solver_instance_t * instance
    )
{
    int depth;
    fcs_move_stack_alloc_into_var(instance->solution_moves);
    /* The moves are inserted from the highest depth to depth 0 in order
       to preserve their order stack-wise
    */

/* #define MYDEBUG */
#ifdef MYDEBUG
    {
        int sum = 0;
        for( depth=0 ; depth <= instance->num_solution_states-2 ; depth++)
        {
            sum += instance->proto_solution_moves[depth]->num_moves;
            printf("depth %i : %i\n", depth, sum);
        }
    }
#endif

    for(depth=instance->instance_num_solution_states-2;depth>=0;depth--)
    {
        freecell_solver_move_stack_swallow_stack(
            instance->solution_moves,
            instance->proto_solution_moves[depth]
            );
    }
    free(instance->proto_solution_moves);
    instance->proto_solution_moves = NULL;
}

/*
    This function optimizes the solution path using a BFS scan on the
    states in the solution path.
*/
static int freecell_solver_optimize_solution(
    freecell_solver_instance_t * instance
    )
{
    instance->optimization_thread = alloc_hard_thread(instance);
    instance->optimization_thread->soft_threads[0]->method = FCS_METHOD_OPTIMIZE;
    /*
     * We do not need to initialize its test order because it inherits the
     * master test order of the instance
     * */

    /* Initialize the optimization hard-thread and soft-thread */
    instance->optimization_thread->num_times_left_for_soft_thread = 1000000;
    freecell_solver_state_ia_init(instance->optimization_thread);

    /* Clean the solution that the non-optimized scan brought us */
    {
        int d;
        for(d=0;d<instance->instance_num_solution_states-1;d++)
        {
            fcs_clean_state(instance->instance_solution_states[d]);
            free(instance->instance_solution_states[d]);
            fcs_move_stack_destroy(instance->proto_solution_moves[d]);
        }
        /* There's one more state than move stack */
        fcs_clean_state(instance->instance_solution_states[d]);
        free(instance->instance_solution_states[d]);

        free(instance->instance_solution_states);
        instance->instance_solution_states = NULL;

        free(instance->proto_solution_moves);
        instance->proto_solution_moves = NULL;
    }

    /* Instruct the optimization hard thread to run indefinitely AFA it
     * is concerned */
    instance->optimization_thread->max_num_times = -1;
    instance->optimization_thread->ht_max_num_times = -1;


    return freecell_solver_a_star_or_bfs_solve(
        instance->optimization_thread->soft_threads[0],
        instance->state_copy_ptr
        );
}


extern void freecell_solver_cache_talon(
    freecell_solver_instance_t * instance,
    fcs_state_with_locations_t * new_state
    );

/*
    This function starts the solution process _for the first time_. If one
    wishes to proceed after the iterations limit was reached, one should
    use freecell_solver_resume_instance.

  */
int freecell_solver_solve_instance(
    freecell_solver_instance_t * instance,
    fcs_state_with_locations_t * init_state
    )
{
    fcs_state_with_locations_t * state_copy_ptr;

    /* Allocate the first state and initialize it to init_state */
    fcs_state_ia_alloc_into_var(state_copy_ptr, instance->hard_threads[0]);

    fcs_duplicate_state(*state_copy_ptr, *init_state);

    /* Initialize the state to be a base state for the game tree */
    state_copy_ptr->depth = 0;
    state_copy_ptr->moves_to_parent = NULL;
    state_copy_ptr->visited = 0;
    state_copy_ptr->parent = NULL;
    memset(&(state_copy_ptr->scan_visited), '\0', sizeof(state_copy_ptr->scan_visited));

    instance->state_copy_ptr = state_copy_ptr;

    /* Initialize the data structure that will manage the state collection */
#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_LIBREDBLACK_TREE)
    instance->tree = rbinit(freecell_solver_state_compare_with_context, NULL);
#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_LIBAVL_AVL_TREE)
    instance->tree = avl_create(freecell_solver_state_compare_with_context, NULL);
#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_LIBAVL_REDBLACK_TREE)
    instance->tree = rb_create(freecell_solver_state_compare_with_context, NULL);
#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_GLIB_TREE)
    instance->tree = g_tree_new(freecell_solver_state_compare);
#endif

#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_GLIB_HASH)
    instance->hash = g_hash_table_new(
        freecell_solver_hash_function,
        freecell_solver_state_compare_equal
        );
#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_INTERNAL_HASH)
    instance->hash = freecell_solver_hash_init(
            2048,
            freecell_solver_state_compare_with_context,
            NULL
       );
#endif

    /****************************************************/

#ifdef INDIRECT_STACK_STATES
    /* Initialize the data structure that will manage the stack
       collection */
#if FCS_STACK_STORAGE == FCS_STACK_STORAGE_INTERNAL_HASH
    instance->stacks_hash = freecell_solver_hash_init(
            2048,
            fcs_stack_compare_for_comparison_with_context,
            NULL
        );
#elif (FCS_STACK_STORAGE == FCS_STACK_STORAGE_LIBAVL_AVL_TREE)
    instance->stacks_tree = avl_create(
            fcs_stack_compare_for_comparison_with_context,
            NULL
            );
#elif (FCS_STACK_STORAGE == FCS_STACK_STORAGE_LIBAVL_REDBLACK_TREE)
    instance->stacks_tree = rb_create(
            fcs_stack_compare_for_comparison_with_context,
            NULL
            );
#elif (FCS_STACK_STORAGE == FCS_STACK_STORAGE_LIBREDBLACK_TREE)
    instance->stacks_tree = rbinit(
        fcs_stack_compare_for_comparison_with_context,
        NULL
        );
#elif (FCS_STACK_STORAGE == FCS_STACK_STORAGE_GLIB_TREE)
    instance->stacks_tree = g_tree_new(fcs_stack_compare_for_comparison);
#elif (FCS_STACK_STORAGE == FCS_STACK_STORAGE_GLIB_HASH)
    instance->stacks_hash = g_hash_table_new(
        freecell_solver_glib_hash_stack_hash_function,
        freecell_solver_glib_hash_stack_compare
        );
#endif
#endif

    /***********************************************/

#ifdef FCS_WITH_TALONS
    /* Initialize the Talon's Cache */
    if (instance->talon_type == FCS_TALON_KLONDIKE)
    {
        instance->talons_hash = freecell_solver_hash_init(
            512,
            fcs_talon_compare_with_context,
            NULL
            );

        freecell_solver_cache_talon(instance, instance->state_copy_ptr);
    }
#endif

#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_DB_FILE)
    /* Not working - ignore */
    db_open(
        NULL,
        DB_BTREE,
        O_CREAT|O_RDWR,
        0777,
        NULL,
        NULL,
        &(instance->db)
        );
#endif

    {
        fcs_state_with_locations_t * no_use;

        freecell_solver_check_and_add_state(
            instance->hard_threads[0]->soft_threads[0],
            state_copy_ptr,
            &no_use,
            0
            );
    }

    instance->ht_idx = 0;
    {
        int ht_idx;
        for(ht_idx=0; ht_idx < instance->num_hard_threads ; ht_idx++)
        {
            instance->hard_threads[ht_idx]->st_idx = 0;
        }
    }

    return freecell_solver_resume_instance(instance);
}





/* Resume a solution process that was stopped in the middle */
int freecell_solver_resume_instance(
    freecell_solver_instance_t * instance
    )
{
    int ret;
    freecell_solver_hard_thread_t * hard_thread;
    freecell_solver_soft_thread_t * soft_thread;
    int num_times_started_at;

    /*
     * If the optimization thread is defined, it means we are in the 
     * optimization phase of the total scan. In that case, just call
     * its scanning function.
     *
     * Else, proceed with the normal total scan.
     * */
    if (instance->optimization_thread)
    {
        ret =
            freecell_solver_a_star_or_bfs_solve(
                instance->optimization_thread->soft_threads[0],
                instance->state_copy_ptr
            );
    }
    else
    {
        /*
         * instance->num_hard_threads_finished signals to us that
         * all the incomplete soft threads terminated. It is necessary
         * in case the scan only contains incomplete threads.
         *
         * I.e: 01235 and 01246, where no thread contains all tests.
         * */
        while(instance->num_hard_threads_finished < instance->num_hard_threads)
        {
            /*
             * A loop on the hard threads.
             * Note that we do not initialize instance->ht_idx because:
             * 1. It is initialized before the first call to this function.
             * 2. It is reset to zero below.
             * */
            for(;
                instance->ht_idx < instance->num_hard_threads ;
                    instance->ht_idx++)
            {
                hard_thread = instance->hard_threads[instance->ht_idx];
                /* 
                 * Again, making sure that not all of the soft_threads in this 
                 * hard thread are finished.
                 * */
                while(hard_thread->num_soft_threads_finished < hard_thread->num_soft_threads)
                {
                    soft_thread = hard_thread->soft_threads[hard_thread->st_idx];
                    /*
                     * Move to the next thread if it's already finished
                     * */
                    if (soft_thread->is_finished)
                    {
                        /*
                         * Hmmpf - duplicate code. That's ANSI C for you.
                         * A macro, anyone?
                         * */

                        /*
                         * Switch to the next soft thread in the hard thread,
                         * since we are going to call continue and this is
                         * a while loop
                         * */
                        hard_thread->st_idx++;
                        if (hard_thread->st_idx == hard_thread->num_soft_threads)
                        {
                            hard_thread->st_idx = 0;
                        }
                        continue;
                    }

                    /*
                     * Keep record of the number of iterations since this 
                     * thread started.
                     * */
                    num_times_started_at = hard_thread->num_times;
                    /*
                     * Calculate a soft thread-wise limit for this hard
                     * thread to run.
                     * */
                    hard_thread->max_num_times = hard_thread->num_times + hard_thread->num_times_left_for_soft_thread;



                    /* 
                     * Call the resume or solving function that is specific 
                     * to each scan
                     * 
                     * This switch-like construct calls for declaring a class
                     * that will abstract a scan. But it's not critical since
                     * I don't support user-defined scans.
                     * */
                    if (soft_thread->method == FCS_METHOD_HARD_DFS)
                    {
                        if (! soft_thread->initialized)
                        {
                            ret = freecell_solver_hard_dfs_solve_for_state(
                                soft_thread,
                                instance->state_copy_ptr,
                                0,
                                0);

                            soft_thread->initialized = 1;
                        }
                        else
                        {
                            ret = freecell_solver_hard_dfs_resume_solution(soft_thread, 0);
                        }
                    }
                    else if (soft_thread->method == FCS_METHOD_SOFT_DFS)
                    {
                        if (! soft_thread->initialized)
                        {
                            ret = freecell_solver_soft_dfs_solve(
                                soft_thread,
                                instance->state_copy_ptr
                                );
                            soft_thread->initialized = 1;
                        }
                        else
                        {
                            ret = freecell_solver_soft_dfs_resume_solution(
                                soft_thread
                                );
                        }
                    }
                    else if (soft_thread->method == FCS_METHOD_RANDOM_DFS)
                    {
                        if (! soft_thread->initialized)
                        {
                            ret = freecell_solver_random_dfs_solve(
                                soft_thread,
                                instance->state_copy_ptr
                                );

                            soft_thread->initialized = 1;
                        }
                        else
                        {
                            ret = freecell_solver_random_dfs_resume_solution(
                                soft_thread
                                );
                        }
                    }
                    else if ((soft_thread->method == FCS_METHOD_BFS) || (soft_thread->method == FCS_METHOD_A_STAR) || (soft_thread->method == FCS_METHOD_OPTIMIZE))
                    {
                        if (! soft_thread->initialized)
                        {
                            if (soft_thread->method == FCS_METHOD_A_STAR)
                            {
                                freecell_solver_a_star_initialize_rater(
                                    soft_thread,
                                    instance->state_copy_ptr
                                    );
                            }

                            ret = freecell_solver_a_star_or_bfs_solve(
                                soft_thread,
                                instance->state_copy_ptr
                                );

                            soft_thread->initialized = 1;
                        }
                        else
                        {
                            ret = freecell_solver_a_star_or_bfs_resume_solution(
                                soft_thread
                                );
                        }
                    }
                    else
                    {
                        ret = FCS_STATE_IS_NOT_SOLVEABLE;
                    }

                    /*
                     * Determine how much iterations we still have left
                     * */
                    hard_thread->num_times_left_for_soft_thread -= (hard_thread->num_times - num_times_started_at);

                    /*
                     * I use <= instead of == because it is possible that 
                     * there will be a few more iterations than what this
                     * thread was allocated, due to the fact that
                     * check_and_add_state is only called by the test 
                     * functions.
                     *
                     * It's a kludge, but it works.
                     * */
                    if (hard_thread->num_times_left_for_soft_thread <= 0)
                    {
                        /* 
                         * Switch to the next soft thread within the hard
                         * thread
                         * */
                        hard_thread->st_idx++;
                        if (hard_thread->st_idx == hard_thread->num_soft_threads)
                        {
                            hard_thread->st_idx = 0;
                        }
                        /* 
                         * Reset num_times_left_for_soft_thread 
                         * */
                        hard_thread->num_times_left_for_soft_thread = hard_thread->soft_threads[hard_thread->st_idx]->num_times_step;
                    }

                    /*
                     * It this thread indicated that the scan was finished,
                     * disable the thread or even stop searching altogether.
                     * */
                    if (ret == FCS_STATE_IS_NOT_SOLVEABLE)
                    {
                        soft_thread->is_finished = 1;
                        hard_thread->num_soft_threads_finished++;
                        if (hard_thread->num_soft_threads_finished == hard_thread->num_soft_threads)
                        {
                            instance->num_hard_threads_finished++;
                        }
                        /*
                         * Check if this thread is a complete scan and if so,
                         * terminate the search
                         * */
                        if (soft_thread->is_a_complete_scan)
                        {
                            goto end_of_hard_threads_loop;
                        }
                        else
                        {
                            /* 
                             * Else, make sure ret is something more sensible
                             * */
                            ret = FCS_STATE_SUSPEND_PROCESS;
                        }
                    }

                    if ((ret == FCS_STATE_WAS_SOLVED) ||
                        (
                            (ret == FCS_STATE_SUSPEND_PROCESS) &&
                            /* There's a limit to the scan only 
                             * if max_num_times is greater than 0 */
                            (
                                (
                                    (instance->max_num_times > 0) &&
                                    (instance->num_times >= instance->max_num_times)
                                ) ||
                                (
                                    (instance->max_num_states_in_collection > 0) &&
                                    (instance->num_states_in_collection >= instance->max_num_states_in_collection)
                                    
                                )
                            )
                        )
                       )
                    {
                        goto end_of_hard_threads_loop;
                    }
                    else if ((ret == FCS_STATE_SUSPEND_PROCESS) &&
                        (hard_thread->num_times >= hard_thread->ht_max_num_times))
                    {
                        hard_thread->ht_max_num_times += hard_thread->num_times_step;
                        break;
                    }
                }
            }
            /* 
             * Avoid over-flow 
             * */
            if (instance->ht_idx == instance->num_hard_threads)
            {
                instance->ht_idx = 0;
            }
        }

        end_of_hard_threads_loop:

        /*
         * If all the incomplete scans finished, then terminate.
         * */
        if (instance->num_hard_threads_finished == instance->num_hard_threads)
        {
            ret = FCS_STATE_IS_NOT_SOLVEABLE;
        }

        if (ret == FCS_STATE_WAS_SOLVED)
        {
            /* Create proto_solution_moves in the first place */
            trace_solution(instance);
        }
    }


    if (ret == FCS_STATE_WAS_SOLVED)
    {
        if (instance->optimize_solution_path)
        {
            ret = freecell_solver_optimize_solution(instance);
            if (ret == FCS_STATE_WAS_SOLVED)
            {
                /* Create the proto_solution_moves in the first place */
                trace_solution(instance);
            }
        }
    }

    if (ret == FCS_STATE_WAS_SOLVED)
    {
        create_total_moves_stack(instance);
    }

    return ret;
}



/*
    Clean up a solving process that was terminated in the middle.
    This function does not substitute for later calling
    finish_instance() and free_instance().
  */
void freecell_solver_unresume_instance(
    freecell_solver_instance_t * instance
    )
{
    /*
     * Do nothing - since finish_instance() can take care of solution_states
     * and proto_solution_moves as they were created by these scans, then
     * I don't need to do it here, too
     *
     * */
}


#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_LIBAVL_AVL_TREE) || (FCS_STATE_STORAGE == FCS_STATE_STORAGE_LIBAVL_REDBLACK_TREE)

static void freecell_solver_tree_do_nothing(void * data, void * context)
{
}

#endif


/* A function for freeing a stack for the cleanup of the
   stacks collection
*/
#ifdef INDIRECT_STACK_STATES
#if (FCS_STACK_STORAGE == FCS_STACK_STORAGE_INTERNAL_HASH) || (FCS_STACK_STORAGE == FCS_STACK_STORAGE_LIBAVL_AVL_TREE) || (FCS_STACK_STORAGE == FCS_STACK_STORAGE_LIBAVL_REDBLACK_TREE)
static void freecell_solver_stack_free(void * key, void * context)
{
    free(key);
}

#elif FCS_STACK_STORAGE == FCS_STACK_STORAGE_LIBREDBLACK_TREE
static void freecell_solver_libredblack_walk_destroy_stack_action
(
    const void * nodep,
    const VISIT which,
    const int depth,
    void * arg
 )
{
    if ((which == leaf) || (which == preorder))
    {
        free((void*)nodep);
    }
}
#elif FCS_STACK_STORAGE == FCS_STACK_STORAGE_GLIB_TREE
static gint freecell_solver_glib_tree_walk_destroy_stack_action
(
    gpointer key,
    gpointer value,
    gpointer data
)
{
    free(key);

    return 0;
}

#elif FCS_STACK_STORAGE == FCS_STACK_STORAGE_GLIB_HASH
static void freecell_solver_glib_hash_foreach_destroy_stack_action
(
    gpointer key,
    gpointer value,
    gpointer data
)
{
    free(key);
}
#endif

#endif

/***********************************************************/




void freecell_solver_destroy_move_stack_of_state(
        fcs_state_with_locations_t * ptr_state_with_locations,
        void * context
        )
{
    if (ptr_state_with_locations->moves_to_parent != NULL)
    {
        fcs_move_stack_destroy(ptr_state_with_locations->moves_to_parent);
    }
}

/*
    This function should be called after the user has retrieved the
    results generated by the scan as it will destroy them.
  */
void freecell_solver_finish_instance(
    freecell_solver_instance_t * instance
    )
{
    int ht_idx;

#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_INDIRECT)
    free(instance->indirect_prev_states);
#endif

    /* De-allocate the state packs */
    for(ht_idx=0;ht_idx<instance->num_hard_threads;ht_idx++)
    {
        /* Destroy all the intermediate move stacks in the solution graph */
        freecell_solver_state_ia_foreach(instance->hard_threads[ht_idx], freecell_solver_destroy_move_stack_of_state, NULL);

        freecell_solver_state_ia_finish(instance->hard_threads[ht_idx]);
    }

    if (instance->optimization_thread)
    {
        freecell_solver_state_ia_foreach(
            instance->optimization_thread,
            freecell_solver_destroy_move_stack_of_state,
            NULL
            );

        freecell_solver_state_ia_finish(instance->optimization_thread);
    }


    /* De-allocate the state collection */
#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_LIBREDBLACK_TREE)
    rbdestroy(instance->tree);
#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_LIBAVL_AVL_TREE)
    avl_destroy(instance->tree, freecell_solver_tree_do_nothing);
#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_LIBAVL_REDBLACK_TREE)
    rb_destroy(instance->tree, freecell_solver_tree_do_nothing);
#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_GLIB_TREE)
    g_tree_destroy(instance->tree);
#endif

#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_GLIB_HASH)
    g_hash_table_destroy(instance->hash);
#elif (FCS_STATE_STORAGE == FCS_STATE_STORAGE_INTERNAL_HASH)
    freecell_solver_hash_free(instance->hash);
#endif



    /* De-allocate the stack collection while free()'ing the stacks
    in the process */
#ifdef INDIRECT_STACK_STATES
#if FCS_STACK_STORAGE == FCS_STACK_STORAGE_INTERNAL_HASH
    freecell_solver_hash_free_with_callback(instance->stacks_hash, freecell_solver_stack_free);
#elif (FCS_STACK_STORAGE == FCS_STACK_STORAGE_LIBAVL_AVL_TREE)
    avl_destroy(instance->stacks_tree, freecell_solver_stack_free);
#elif (FCS_STACK_STORAGE == FCS_STACK_STORAGE_LIBAVL_REDBLACK_TREE)
    rb_destroy(instance->stacks_tree, freecell_solver_stack_free);
#elif (FCS_STACK_STORAGE == FCS_STACK_STORAGE_LIBREDBLACK_TREE)
    rbwalk(instance->stacks_tree,
        freecell_solver_libredblack_walk_destroy_stack_action,
        NULL
        );
    rbdestroy(instance->stacks_tree);
#elif (FCS_STACK_STORAGE == FCS_STACK_STORAGE_GLIB_TREE)
    g_tree_traverse(
        instance->stacks_tree,
        freecell_solver_glib_tree_walk_destroy_stack_action,
        G_IN_ORDER,
        NULL
        );

    g_tree_destroy(instance->stacks_tree);
#elif (FCS_STACK_STORAGE == FCS_STACK_STORAGE_GLIB_HASH)
    g_hash_table_foreach(
        instance->stacks_hash,
        freecell_solver_glib_hash_foreach_destroy_stack_action,
        NULL
        );
    g_hash_table_destroy(instance->stacks_hash);
#endif
#endif

#if (FCS_STATE_STORAGE == FCS_STATE_STORAGE_DB_FILE)
    instance->db->close(instance->db,0);
#endif


    clean_soft_dfs(instance);


    if (instance->proto_solution_moves != NULL)
    {
        free(instance->proto_solution_moves);
        instance->proto_solution_moves = NULL;
    }

    if (instance->instance_solution_states != NULL)
    {
        free(instance->instance_solution_states);
        instance->instance_solution_states = NULL;
    }
}

freecell_solver_soft_thread_t * freecell_solver_instance_get_soft_thread(
        freecell_solver_instance_t * instance,
        int ht_idx,
        int st_idx
        )
{
    if (ht_idx >= instance->num_hard_threads)
    {
        return NULL;
    }
    else
    {
        freecell_solver_hard_thread_t * hard_thread;
        hard_thread = instance->hard_threads[ht_idx];
        if (st_idx >= hard_thread->num_soft_threads)
        {
            return NULL;
        }
        else
        {
            return hard_thread->soft_threads[st_idx];
        }
    }
}

freecell_solver_soft_thread_t * freecell_solver_new_soft_thread(
    freecell_solver_soft_thread_t * soft_thread
    )
{
    freecell_solver_soft_thread_t * ret;
    freecell_solver_hard_thread_t * hard_thread;

    hard_thread = soft_thread->hard_thread;
    ret = alloc_soft_thread(hard_thread);

    /* Exceeded the maximal number of Soft-Threads in an instance */
    if (ret == NULL)
    {
        return NULL;
    }

    hard_thread->soft_threads = realloc(hard_thread->soft_threads, sizeof(hard_thread->soft_threads[0])*(hard_thread->num_soft_threads+1));
    hard_thread->soft_threads[hard_thread->num_soft_threads] = ret;
    hard_thread->num_soft_threads++;

    return ret;
}

freecell_solver_soft_thread_t * freecell_solver_new_hard_thread(
    freecell_solver_instance_t * instance
    )
{
    freecell_solver_hard_thread_t * ret;

    /* Exceeded the maximal number of Soft-Threads in an instance */
    ret = alloc_hard_thread(instance);

    if (ret == NULL)
    {
        return NULL;
    }

    instance->hard_threads =
        realloc(
            instance->hard_threads,
            (sizeof(instance->hard_threads[0]) * (instance->num_hard_threads+1))
            );

    instance->hard_threads[instance->num_hard_threads] = ret;

    instance->num_hard_threads++;

    return ret->soft_threads[0];
}
