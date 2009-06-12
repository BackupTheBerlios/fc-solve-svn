ignore_list = %w{
    DB DBT DB_BTREE FCS_MOVE_TYPE_NULL FCS_MOVE_TYPE_SEPARATOR
    FCS_STATE_OPTIMIZED FCS_STATE_ORIGINAL_STATE_IS_NOT_SOLVEABLE
    FREECELL_SOLVER_PREFIX Judy O_CREAT O_RDWR PACKAGE PACKAGE_BUGREPORT
    PACKAGE_NAME PACKAGE_STRING PACKAGE_TARNAME PACKAGE_VERSION
    PTHREAD_MUTEX_INITIALIZER SEEK_SET SIGUSR1 SIGUSR2
    __attribute__ arg_index atof bsearch
    close db_open do fc_solve_hash_c_dummy
    fc_solve_simple_simon_nothing fcntl
    fcs_libavl2_stacks_tree_create
    fcs_libavl2_stacks_tree_destroy
    fcs_libavl2_stacks_tree_insert
    fcs_libavl2_stacks_tree_table_t
    fcs_libavl2_states_tree_create
    fcs_libavl2_states_tree_destroy
    fcs_libavl2_states_tree_insert
    fcs_libavl2_states_tree_table_t
    fgets
    get
    gint
    glib
    gypsy_talon
    gypsy_talon_len
    lp_instance
    no
    pthread
    pthread_create
    pthread_join
    pthread_t
    put
    qsort
    redblack
    short
    stat
    stdin
    strcat
    strchr
    strnicmp
    union
    unistd
    unused
    va_list
    va_start
    vsprintf
    Column
    END_OF_LOOP
    FCS_A_STAR_WEIGHT_CARDS_OUT
    FCS_A_STAR_WEIGHT_CARDS_UNDER_SEQUENCES
    FCS_A_STAR_WEIGHT_DEPTH
    FCS_A_STAR_WEIGHT_MAX_SEQUENCE_MOVE
    FCS_A_STAR_WEIGHT_SEQS_OVER_RENEGADE_CARDS
    FCS_CMD_LINE_USER
    FCS_COMPILE_PRELUDE_NO_AT_SIGN
    FCS_COMPILE_PRELUDE_OK
    FCS_COMPILE_PRELUDE_UNKNOWN_SCAN_ID
    FCS_FOUNDATIONS_OFFSET
    FCS_INLINE_KEYWORD
    FCS_METHOD_HARD_DFS
    FCS_METHOD_NONE
    FCS_MOVE_NUM_CARDS_FLIPPED
    FCS_MOVE_TYPE_DEAL_GYPSY_TALON
    FCS_MOVE_TYPE_KLONDIKE_FLIP_TALON
    FCS_MOVE_TYPE_KLONDIKE_REDEAL_TALON
    FCS_MOVE_TYPE_KLONDIKE_TALON_TO_STACK
    FCS_PRESET_CODE_DECKS_EXCEED_MAX
    FCS_PRESET_YUKON
    FCS_STATE_DOES_NOT_EXIST
    FCS_STATE_EXCEEDS_MAX_DEPTH
    FCS_USER_STATE_TO_C__PREMATURE_END_OF_INPUT
    FCS_WITHOUT_GET_BOARD
    FC_SOLVE__ALLOC_H
    FC_SOLVE__APP_STR_H
    FC_SOLVE__CAAS_C
    FC_SOLVE__CARD_H
    FC_SOLVE__CHECK_AND_ADD_STATE_H
    FC_SOLVE__CHECK_LIMITS_H
    FC_SOLVE__CONFIG_H
    FC_SOLVE__FCS_CL_H
    FC_SOLVE__FCS_DATA_H
    FC_SOLVE__FCS_ENUMS_H
    FC_SOLVE__FCS_H
    FC_SOLVE__FCS_HASH_H
    FC_SOLVE__FCS_ISA_H
    FC_SOLVE__FCS_MOVE_H
    FC_SOLVE__FCS_USER_H
    FC_SOLVE__FC_PRO_IFACE_POS_H
    FC_SOLVE__FREECELL_H
    FC_SOLVE__INLINE_H
    FC_SOLVE__META_MOVE_FUNCS_HELPERS_H
    FC_SOLVE__MOVE_H
    FC_SOLVE__MOVE_STACK_COMPACT_ALLOC_H
    FC_SOLVE__PQUEUE_H
    FC_SOLVE__PRESET_H
    FC_SOLVE__RAND_H
    FC_SOLVE__RANGE_SOLVERS_GEN_MS_BOARDS_H
    FC_SOLVE__SCANS_H
    FC_SOLVE__SIMPSIM_H
    FC_SOLVE__SPLIT_CMD_LINE_H
    FC_SOLVE__STATE_H
    FC_SOLVE__UNUSED_H
    FREECELL_SOLVER_PKG_DATA_DIR
    GHashTable
    GTree
    HAVE_C_INLINE
    have_preset
    JHSFA
    JHSI
    loop_start
    MAXCOL
    MAXPOS
    PQUEUE_MaxRating
    PQ_LEFT_CHILD_INDEX
    PQueueIsEmpty
    VERSION
    Word_t
    accumulate_tests_order
    callback_choice
    calloc
    clean_soft_dfs
    allowed_tests
    determine_scan_completeness
    soft_thread_clean_soft_dfs
    card_idx
    card_to_string_suits
    card_to_string_values
    child_suit
    command_signal_handler
    compile_prelude
    condition_expr
    derived_states
    derived_states_compare_callback
    dest_c
    dummy
    elem
    end_idx
    end_of_hard_threads_loop
    existing_key_void
    fc_pro_get_board
    fc_solve_glib_hash_stack_compare
    fc_solve_glib_hash_stack_hash_function
    fc_solve_initialize_bfs_queue
    fc_solve_move_sequence_function
    fc_solve_optimize_solution
    fc_solve_rand_get_random_number
    fc_solve_solve_for_state_test_t
    fcs_compact_alloc_release
    fcs_freecell_card_suit
    fcs_get_preset_by_id
    fcs_instance_item_t
    fcs_klondike_talon_decrement_stack
    fcs_klondike_talon_queue_to_stack
    fcs_klondike_talon_redeal_bare
    fcs_move_set_num_cards_flipped
    fcs_get_preset_id_by_name
    fcs_preset_name_t
    fcs_state_init
    final_ret
    foundations_prefixes
    free_instance_soft_thread_callback
    freecell_solver_user_get_current_depth
    freecell_solver_user_get_limit_iterations
    freecell_solver_user_get_num_soft_threads_in_instance
    freecell_solver_user_move_to_string
    freecell_solver_user_next_instance
    freecell_solver_user_set_game
    fcs_u2p_flipped_status
    freecells_prefixes
    from
    g_hash_table_destroy
    g_hash_table_insert
    g_hash_table_lookup
    g_hash_table_new
    g_tree_destroy
    g_tree_insert
    g_tree_lookup
    g_tree_new
    global_tests_order
    help_screen_t
    how_much_orig
    initialize_a_star_rater
    inline
    into
    is_whitespace
    isdigit
    iter_handler_wrapper
    length
    memmove
    microsoft_rand_t
    nc1
    nc2
    new_move
    no_use_val
    normalize_a_star_weights
    not_append_ws
    num_redeals_prefixes
    old_buffer
    opened_files_dir_to_assign
    p1
    p2
    parent_suit
    ptr_state_input_val
    ptr_state_void
    ranks_map
    rbdestroy
    rbinit
    rbsearch
    rbtree
    read_preset
    rehash_check
    run_hard_thread
    screen
    select_signal_handler
    signal_num
    src_c
    src_col
    start_idx
    stdarg
    stddef
    suits_map
    talon_prefixes
    tests_order_dup
    toupper
    type_t
    user_preset_dir
    void_a
    void_b
    void_context
    worker_thread
    alloc_soft_thread
    int
    if
    instance
    endif
    void
    define
    soft_thread
    char
    user
    return
    else
    ret
    for
    card
    include
    hard_thread
    break
    ifndef
    talon_len
    synergy
}


ignore = Hash.new
for s in ignore_list do
    ignore[s] = 1
end

col = Hash.new
ARGV.each do |fn|
    if fn == "test_inline.c"
        next
    end
    File.open(fn, "r") do |file|
        line_num = 1
        while (l = file.gets)
            l.gsub!(/\/\*.*?\*\//m, ""); 
            l.gsub!(/(?:"([^\\]|\\.)*?")|(?:'[^'']+?')/m, " ");
            if (m = /\A(.*?)((?:\/\*)|\z)/m.match(l))
                before = m[1]
                open_comment = m[2]
                before.scan(/\b([a-zA-Z_]\w+)/).each{
                    |s| id = s[0]; col[id] ||= Array.new; col[id] << [fn, line_num]
                }
                if (open_comment == "/*")
                    found_line = false
                    while (l = file.gets)
                        line_num += 1
                        if (l.gsub!(/\A.*?\*\//, ""))
                            found_line = true
                            break
                        end
                    end
                    if (found_line)
                        redo
                    end
                else
                    line_num += 1                
                end
            end
        end
    end
end

puts col.keys.select { |id| !ignore[id] }. \
    sort_by { |x| [col[x].length,x] }. \
    map{ |x| col[x].map { |arr| arr[0] + ":" + arr[1].to_s + ":" + x }}. \
    flatten