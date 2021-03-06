/*
 * preset.c - game presets management for Freecell Solver
 *
 * Written by Shlomi Fish (shlomif@vipe.technion.ac.il), 2000
 *
 * This file is in the public domain (it's uncopyrighted).
 *
 */


#include <string.h>

#include "fcs.h"
#include "preset.h"

#ifdef DMALLOC
#include "dmalloc.h"
#endif


struct fcs_preset_struct
{
    int preset_id;
    int freecells_num;
    int stacks_num;
    int decks_num;

    int sequences_are_built_by;
    int unlimited_sequence_move;
    int empty_stacks_fill;

    char tests_order[FCS_TESTS_NUM*3+1];
    char allowed_tests[FCS_TESTS_NUM*3+1];
};

typedef struct fcs_preset_struct fcs_preset_t;

enum fcs_presets_ids
{
    FCS_PRESET_BAKERS_DOZEN,
    FCS_PRESET_BAKERS_GAME,
    FCS_PRESET_CRUEL,
    FCS_PRESET_DER_KATZENSCHWANZ,
    FCS_PRESET_DIE_SCHLANGE,
    FCS_PRESET_EIGHT_OFF,
    FCS_PRESET_FORECELL,
    FCS_PRESET_FREECELL,
    FCS_PRESET_GOOD_MEASURE,
    FCS_PRESET_KINGS_ONLY_BAKERS_GAME,
    FCS_PRESET_RELAXED_FREECELL,
    FCS_PRESET_RELAXED_SEAHAVEN_TOWERS,
    FCS_PRESET_SEAHAVEN_TOWERS,
    FCS_PRESET_SIMPLE_SIMON,
    FCS_PRESET_YUKON,
    FCS_PRESET_BELEAGUERED_CASTLE,
};

static const fcs_preset_t fcs_presets[15] = 
{
    {
        FCS_PRESET_BAKERS_DOZEN,
        0,
        13,
        1,

        FCS_SEQ_BUILT_BY_RANK,
        0,
        FCS_ES_FILLED_BY_NONE,

        "0123456789",
        "0123456789",
    },
    {
        FCS_PRESET_BAKERS_GAME,
        4,
        8,
        1,

        FCS_SEQ_BUILT_BY_SUIT,
        0,
        FCS_ES_FILLED_BY_ANY_CARD,

        "[01][23456789]",
        "0123456789",
    },
    {
        FCS_PRESET_BELEAGUERED_CASTLE,
        0,
        8,
        1,

        FCS_SEQ_BUILT_BY_RANK,
        0,
        FCS_ES_FILLED_BY_ANY_CARD,

        "[01][23456789]",
        "0123456789",
    },
    {
        FCS_PRESET_CRUEL,
        0,
        12,
        1,

        FCS_SEQ_BUILT_BY_SUIT,
        0,
        FCS_ES_FILLED_BY_NONE,

        "0123456789",
        "0123456789",
    },
    {
        FCS_PRESET_DER_KATZENSCHWANZ,
        8,
        9,
        2,

        FCS_SEQ_BUILT_BY_ALTERNATE_COLOR,
        1,
        FCS_ES_FILLED_BY_NONE,

        "[01][23456789]",
        "0123456789",
    },
    {
        FCS_PRESET_DIE_SCHLANGE,
        8,
        9,
        2,

        FCS_SEQ_BUILT_BY_ALTERNATE_COLOR,
        0,
        FCS_ES_FILLED_BY_NONE,

        "[01][23456789]",
        "0123456789",
    },
    {
        FCS_PRESET_EIGHT_OFF,
        8,
        8,
        1,

        FCS_SEQ_BUILT_BY_SUIT,
        0,
        FCS_ES_FILLED_BY_KINGS_ONLY,

        "[01][23456789]",
        "0123456789",
    },
    {
        FCS_PRESET_FORECELL,
        4,
        8,
        1,

        FCS_SEQ_BUILT_BY_ALTERNATE_COLOR,
        0,
        FCS_ES_FILLED_BY_KINGS_ONLY,

        "[01][23456789]",
        "0123456789",
    },
    {
        FCS_PRESET_FREECELL,
        4,
        8,
        1,

        FCS_SEQ_BUILT_BY_ALTERNATE_COLOR,
        0,
        FCS_ES_FILLED_BY_ANY_CARD,

        "[01][23456789]",
        "0123456789",
    },
    {
        FCS_PRESET_GOOD_MEASURE,
        0,
        10,
        1,

        FCS_SEQ_BUILT_BY_RANK,
        0,
        FCS_ES_FILLED_BY_NONE,

        "0123456789",
        "0123456789",
    },
    {
        FCS_PRESET_KINGS_ONLY_BAKERS_GAME,
        4,
        8,
        1,

        FCS_SEQ_BUILT_BY_SUIT,
        0,
        FCS_ES_FILLED_BY_KINGS_ONLY,

        "[01][23456789]",
        "0123456789",
    },
    {
        FCS_PRESET_RELAXED_FREECELL,
        4,
        8,
        1,

        FCS_SEQ_BUILT_BY_ALTERNATE_COLOR,
        1,
        FCS_ES_FILLED_BY_ANY_CARD,

        "[01][23456789]",
        "0123456789",
    },
    {
        FCS_PRESET_RELAXED_SEAHAVEN_TOWERS,
        4,
        10,
        1,

        FCS_SEQ_BUILT_BY_SUIT,
        1,
        FCS_ES_FILLED_BY_KINGS_ONLY,

        "[01][23456789]",
        "0123456789",
    },
    {
        FCS_PRESET_SEAHAVEN_TOWERS,
        4,
        10,
        1,

        FCS_SEQ_BUILT_BY_SUIT,
        0,
        FCS_ES_FILLED_BY_KINGS_ONLY,

        "[01][23456789]",
        "0123456789",
    },
    {
        FCS_PRESET_SIMPLE_SIMON,
        0,
        10,
        1,

        FCS_SEQ_BUILT_BY_SUIT,
        0,
        FCS_ES_FILLED_BY_ANY_CARD,

        "abcdefgh",
        "abcdefgh",
    },
};

struct fcs_preset_name_struct
{
    const char name[32];
    int preset_id;
};

typedef struct fcs_preset_name_struct fcs_preset_name_t;

static const fcs_preset_name_t fcs_preset_names[22] =
{
    {
        "bakers_dozen",
        FCS_PRESET_BAKERS_DOZEN,
    },
    {
        "bakers_game",
        FCS_PRESET_BAKERS_GAME,
    },
    {
        "beleaguered_castle",
        FCS_PRESET_BELEAGUERED_CASTLE,
    },
    {
        "citadel",
        FCS_PRESET_BELEAGUERED_CASTLE,
    },
    {
        "cruel",
        FCS_PRESET_CRUEL,
    },
    {
        "der_katzenschwanz",
        FCS_PRESET_DER_KATZENSCHWANZ,
    },
    {
        "der_katz",
        FCS_PRESET_DER_KATZENSCHWANZ,
    },
    {
        "die_schlange",
        FCS_PRESET_DIE_SCHLANGE,
    },
    {
        "eight_off",
        FCS_PRESET_EIGHT_OFF,
    },
    {
        "forecell",
        FCS_PRESET_FORECELL,
    },
    {
        "freecell",
        FCS_PRESET_FREECELL,
    },
    {
        "good_measure",
        FCS_PRESET_GOOD_MEASURE,
    },
    {
        "ko_bakers_game",
        FCS_PRESET_KINGS_ONLY_BAKERS_GAME,
    },
    {
        "kings_only_bakers_game",
        FCS_PRESET_KINGS_ONLY_BAKERS_GAME,
    },
    {
        "relaxed_freecell",
        FCS_PRESET_RELAXED_FREECELL,
    },
    {
        "relaxed_seahaven_towers",
        FCS_PRESET_RELAXED_SEAHAVEN_TOWERS,
    },
    {
        "relaxed_seahaven",
        FCS_PRESET_RELAXED_SEAHAVEN_TOWERS,
    },
    {
        "seahaven_towers",
        FCS_PRESET_SEAHAVEN_TOWERS,
    },
    {
        "seahaven",
        FCS_PRESET_SEAHAVEN_TOWERS,
    },
    {
        "simple_simon",
        FCS_PRESET_SIMPLE_SIMON,
    },
    {
        "streets_and_alleys",
        FCS_PRESET_BELEAGUERED_CASTLE,
    },
    {
        "yukon",
        FCS_PRESET_YUKON,
    },
};

static int fcs_get_preset_id_by_name(
    const char * name
)
{
    int a;
    int ret = -1;
    int num_elems;

    num_elems = ( (int) (sizeof(fcs_preset_names)/sizeof(fcs_preset_names[0])));
    for(a=0;a<num_elems;a++)
    {
        if (!strcmp(name, fcs_preset_names[a].name))
        {
            ret = fcs_preset_names[a].preset_id;
            break;
        }
    }

    return ret;
}

static int freecell_solver_char_to_test_num(char c)
{
    if ((c >= '0') && (c <= '9'))
    {
        return c-'0';
    }
    else if ((c >= 'a') && (c <= 'h'))
    {
        return c-'a'+10;
    }
#if 0
    else if ((c >= 'A') && (c <= 'Z'))
    {
        return c-'A'+18;
    }
#endif
    else
    {
        return 0;
    }
}

#ifndef min
#define min(a,b) (((a)<(b))?(a):(b))
#endif

struct internal_tests_order_struct
{
    int tests_order_num;
    int tests_order[FCS_TESTS_NUM];
};

typedef struct internal_tests_order_struct internal_tests_order_t;

static int get_internal_tests_order(
    const char * string,
    char * * error_string,
    internal_tests_order_t * result
    )
{
    int a;
    int len;
    int test_index;
    int is_group, is_start_group;
    int tests_order[FCS_TESTS_NUM];

#if 0
    instance->tests_order_num = min(strlen(string), FCS_TESTS_NUM);
#endif
    len = strlen(string);
    test_index = 0;
    is_group = 0;
    is_start_group = 0;
    for(a=0;(a<len) && (test_index < FCS_TESTS_NUM);a++)
    {
        if ((string[a] == '(') || (string[a] == '['))
        {
            if (is_group)
            {
                *error_string = strdup("There's a nested random group.");
                return 1;
            }
            is_group = 1;
            is_start_group = 1;
            continue;
        }

        if ((string[a] == ')') || (string[a] == ']'))
        {
            if (is_start_group)
            {
                *error_string = strdup("There's an empty group.");
                return 2;
            }
            if (! is_group)
            {
                *error_string = strdup("There's a renegade right parenthesis or bracket.");
                return 3;
            }
            is_group = 0;
            is_start_group = 0;
            continue;
        }
        tests_order[test_index] = (freecell_solver_char_to_test_num(string[a])%FCS_TESTS_NUM) | (is_group ? FCS_TEST_ORDER_FLAG_RANDOM : 0) | (is_start_group ? FCS_TEST_ORDER_FLAG_START_RANDOM_GROUP : 0);

        test_index++;
        is_start_group = 0;
    }
    if (a != len)
    {
        *error_string = strdup("The Input string is too long.");
        return 4;
    }

    result->tests_order_num = test_index;
    memcpy(result->tests_order, tests_order, sizeof(result->tests_order));
    *error_string = NULL;

    return 0;
}

int freecell_solver_apply_tests_order(
    freecell_solver_soft_thread_t * soft_thread,
    const char * string,
    char * * error_string
    )
{
    internal_tests_order_t to_assign;
    int ret;

    ret = get_internal_tests_order(string, error_string, &to_assign);

    if (ret != 0)
    {
        return ret;
    }

    soft_thread->tests_order_num = to_assign.tests_order_num;
    memcpy(soft_thread->tests_order, to_assign.tests_order, sizeof(soft_thread->tests_order));

    return 0;
}


static int fcs_apply_preset(
    freecell_solver_instance_t * instance,
    int preset_id
    )
{
    int preset_index;
    int num_elems;
    char * no_use;

    num_elems = ( (int) (sizeof(fcs_presets)/sizeof(fcs_presets[0])));

    for(preset_index=0 ; preset_index < num_elems ; preset_index++)
    {
        if (fcs_presets[preset_index].preset_id == preset_id)
        {
#define preset (fcs_presets[preset_index])
            if (preset.freecells_num > MAX_NUM_FREECELLS)
            {
                return FCS_PRESET_CODE_FREECELLS_EXCEED_MAX;
            }
            if (preset.stacks_num > MAX_NUM_STACKS)
            {
                return FCS_PRESET_CODE_STACKS_EXCEED_MAX;
            }
            if (preset.decks_num > MAX_NUM_DECKS)
            {
                return FCS_PRESET_CODE_DECKS_EXCEED_MAX;
            }
            instance->freecells_num = preset.freecells_num;
            instance->stacks_num = preset.stacks_num;
            instance->decks_num = preset.decks_num;

            instance->sequences_are_built_by = preset.sequences_are_built_by;
            instance->unlimited_sequence_move = preset.unlimited_sequence_move;
            instance->empty_stacks_fill = preset.empty_stacks_fill;

            /* 
             * This code makes sure that all the tests in all the existing
             * soft threads are acceptable by the new preset.
             * */

            {
                int ht_idx, st_idx;
                for(ht_idx = 0; ht_idx < instance->num_hard_threads ; ht_idx++)
                {
                    for(st_idx = 0; st_idx < instance->hard_threads[ht_idx]->num_soft_threads; st_idx++)
                    {
                        freecell_solver_soft_thread_t * soft_thread = instance->hard_threads[ht_idx]->soft_threads[st_idx];
                        
                        int num_valid_tests;
                        const char * s;

                        /* Check every test */

                        for(num_valid_tests=0;num_valid_tests < soft_thread->tests_order_num; num_valid_tests++)
                        {
                            for(s = preset.allowed_tests;*s != '\0';s++)
                            {
                                /* Check if this test corresponds to this character */
                                if ((soft_thread->tests_order[num_valid_tests] & FCS_TEST_ORDER_NO_FLAGS_MASK) == ((freecell_solver_char_to_test_num(*s)%FCS_TESTS_NUM)))
                                {
                                    break;
                                }
                            }
                            /* If the end of the string was reached, it means
                             * this test is unacceptable by this preset. */
                            if (*s == '\0')
                            {
                                break;
                            }
                        }
                        if (num_valid_tests < soft_thread->tests_order_num)
                        {
                            freecell_solver_apply_tests_order(
                                    soft_thread,
                                    preset.tests_order,
                                    &no_use);
                        }
                    }
                }
            }

            /* Assign the master tests order */
            
            {
                internal_tests_order_t to_assign;
                get_internal_tests_order(preset.tests_order, &no_use, &to_assign);
                instance->instance_tests_order_num = to_assign.tests_order_num;
                memcpy(instance->instance_tests_order, to_assign.tests_order, sizeof(instance->instance_tests_order));
            }
            return FCS_PRESET_CODE_OK;
        }
    }

    return FCS_PRESET_CODE_NOT_FOUND;
}

int freecell_solver_apply_preset_by_name(
    freecell_solver_instance_t * instance,
    const char * name
    )
{
    int preset_id = fcs_get_preset_id_by_name(name);
    if (preset_id >= 0)
    {
        return (fcs_apply_preset(instance, preset_id));
    }
    else
    {
        return FCS_PRESET_CODE_NOT_FOUND;
    }
}
