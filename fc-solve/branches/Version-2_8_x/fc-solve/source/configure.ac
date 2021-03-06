dnl Process this file with autoconf to produce a configure script.
AC_INIT(pqueue.c)

dnl Checks for programs.
AC_PROG_CC
AC_PROG_MAKE_SET
AC_PROG_RANLIB

AM_INIT_AUTOMAKE(freecell-solver, [`cat ./ver.txt`])

AM_PROG_LIBTOOL

AM_CONFIG_HEADER(config.h)


dnl Checks for libraries.
dnl Replace `main' with a function in -ldb:
dnl AC_CHECK_LIB(db, main)
dnl Replace `main' with a function in -ldl:
dnl AC_CHECK_LIB(dl, main)
dnl Replace `main' with a function in -lglib:
dnl AC_CHECK_LIB(glib, g_hash_table_new)
dnl Replace `main' with a function in -lm:
AC_CHECK_LIB(m, pow)

dnl Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS(limits.h)

state_storage=internal_hash
stack_storage=internal_hash
max_num_freecells=4
max_num_stacks=10
states_type=indirect
max_num_initial_cards_per_stack=8
max_num_decks=2
card_debug_pres=no

AC_ARG_ENABLE(state-storage,
 [  --enable-state-storage[=storage type] Specify a storage types for the state collection:
                      glib_hash: Glib's hash 
                      glib_tree: Glib's binary tree 
                      indirect: By means of a sorted array with a sort margin
                      internal_hash: Internal Hash Storage (Default)
                      libavl_avl: libavl's AVL tree 
                      libavl_redblack: libavl's Red-Black tree
                      libredblack: The libredblack tree],
 [ if   test "x$enableval" = "xglib_hash" ; then
      state_storage=glib_hash
   elif test "x$enableval" = "xglib_tree" ; then
      state_storage=glib_tree
   elif test "x$enableval" = "xindirect" ; then
      state_storage=indirect      
   elif test "x$enableval" = "xinternal_hash" ; then
      state_storage=internal_hash
   elif test "x$enableval" = "xlibavl_avl" ; then
      state_storage=libavl_avl
   elif test "x$enableval" = "xlibavl_redblack" ; then
      state_storage=libavl_redblack
   elif test "x$enableval" = "xlibredblack" ; then
      state_storage=libredblack      
   else
      echo
      echo "Error!"
      echo "Unknown state storage"
      exit -1
   fi
 ])

AC_ARG_ENABLE(stack-storage,
 [  --enable-stack-storage[=storage type] Specify a storage types for the state collection:
                      glib_hash: Glib's hash 
                      glib_tree: Glib's binary tree 
                      internal_hash: Internal Hash Storage (Default)
                      libavl_avl: libavl's AVL tree 
                      libavl_redblack: libavl's Red-Black tree
                      libredblack: The libredblack tree],
 [ if   test "x$enableval" = "xglib_hash" ; then
      stack_storage=glib_hash
   elif test "x$enableval" = "xglib_tree" ; then
      stack_storage=glib_tree
   elif test "x$enableval" = "xinternal_hash" ; then
      stack_storage=internal_hash
   elif test "x$enableval" = "xlibavl_avl" ; then
      stack_storage=libavl_avl
   elif test "x$enableval" = "xlibavl_redblack" ; then
      stack_storage=libavl_redblack
   elif test "x$enableval" = "xlibredblack" ; then
      stack_storage=libredblack      
   else
      echo
      echo "Error!"
      echo "Unknown state storage"
      exit -1
   fi
 ])

AC_ARG_ENABLE(states-type,
 [  --enable-states-type[=state type] Specify the states type:
                      compact: Compact States
                      debug: Debug States (very slow)
                      indirect [default]: Indirect Stack States],
 [ if   test "x$enableval" = "xcompact" ; then
      states_type=compact
   elif test "x$enableval" = "xdebug" ; then
      states_type=debug
   elif test "x$enableval" = "xindirect" ; then
      states_type=indirect      
   else
      echo 
      echo "Error!"
      echo "Unknown states' type"
      exit -1
   fi
 ])


AC_ARG_ENABLE(max-num-freecells,
 [  --enable-max-num-freecells[=freecells num] Set the maximal number of Freecells],
 [ if   test "x$enableval" = "x" ; then
      max_num_freecells=4
   else
       # Check if it's indeed a number
       changequote(, )
       if echo "0$enableval" | grep '[^0-9]' > /dev/null ; then  
           echo 
           echo "Error!"       
           echo "max-num-freecells should be a number!"
           exit -1
       elif expr $enableval \< 4 > /dev/null ; then
           echo
           echo "Error!"
           echo "max-num-freecells cannot be lower than 4!"
           exit -1
       elif expr $enableval \> 20 > /dev/null ; then
           echo 
           echo "Error!"
           echo "max-num-freeecells cannot be greater than 20!"
           exit -1
       else           
           max_num_freecells="$enableval"
       fi       
       changequote([, ])
   fi])

AC_ARG_ENABLE(max-num-stacks,
 [  --enable-max-num-stacks[=stacks num] Set the maximal number of Stacks],
 [ if   test "x$enableval" = "x" ; then
      max_num_stacks=8
   else
       changequote(, )
       # Check if it's indeed a number
       if echo "0$enableval" | grep '[^0-9]' > /dev/null ; then  
           echo 
           echo "Error!"       
           echo "max-num-stacks should be a number!"
           exit -1
       elif expr $enableval \< 8 > /dev/null ; then 
           echo
           echo "Error!"
           echo "max-num-stacks cannot be lower than 8"
           exit -1
       elif expr $enableval \> 20 > /dev/null ; then
           echo 
           echo "Error!"
           echo "max-num-stacks cannot be greater than 20"
           exit -1
       else
           max_num_stacks="$enableval"
       fi       
       changequote([, ])
   fi])

AC_ARG_ENABLE(max-num-initial-cards-per-stack,
 [  --enable-max-num-initial-cards-per-stack[=number] Set the maximal number of Cards that can appear in a stack],
 [ if   test "x$enableval" = "x" ; then
      max_num_initial_cards_per_stack=7
   else
       changequote(, )
       # Check if it's indeed a number
       if echo "0$enableval" | grep '[^0-9]' > /dev/null ; then  
           echo 
           echo "Error!"
           echo "max-num-initial-cards-per-stack should be a number!"
           exit -1
       elif expr $enableval \< 7 > /dev/null ; then
           echo
           echo "Error!"
           echo "max-num-initial-cards-per-stack cannot be lower than 7"
           exit -1
       elif expr $enableval \> 104 > /dev/null ; then
           echo
           echo "Error!"
           echo "max-num-initial-cards-per-stack cannot be greater than 104"
           echo "(the number of cards in two decks"
           exit -1
       else
           max_num_initial_cards_per_stack="$enableval"
       fi
       changequote([, ])
   fi])   

AC_ARG_ENABLE(max-num-decks,
 [  --enable-max-num-decks[=decks num] Set the maximal number of Decks],
 [ if   test "x$enableval" = "x1" ; then
       max_num_decks=1
   elif test "x$enableval" = "x2" ; then
       max_num_decks=2
   else
       echo 
       echo "Error!"   
       echo "Wrong value for max-num-decks. Can be 1 or 2."
       exit -1
   fi])

AC_ARG_ENABLE(card-debug-pres,
 [  --enable-card-debug-pres  Enable Card-Debug Presentation. This is a debugging feature which should not be usually enabled],
 [ card_debug_pres=yes
 ])

 
if   test "x$state_storage" = "xglib_hash" ; then
    AC_DEFINE(FCS_STATE_STORAGE,FCS_STATE_STORAGE_GLIB_HASH)
    requires_glib=yes
elif test "x$state_storage" = "xglib_tree" ; then
    AC_DEFINE(FCS_STATE_STORAGE,FCS_STATE_STORAGE_GLIB_TREE)
    requires_glib=yes
elif test "x$state_storage" = "xindirect" ; then
    AC_DEFINE(FCS_STATE_STORAGE,FCS_STATE_STORAGE_INDIRECT)
elif test "x$state_storage" = "xinternal_hash" ; then
    AC_DEFINE(FCS_STATE_STORAGE,FCS_STATE_STORAGE_INTERNAL_HASH)
elif test "x$state_storage" = "xlibavl_avl" ; then
    AC_DEFINE(FCS_STATE_STORAGE,FCS_STATE_STORAGE_LIBAVL_AVL_TREE)
    requires_libavl=yes
elif test "x$state_storage" = "xlibavl_redblack" ; then
    AC_DEFINE(FCS_STATE_STORAGE,FCS_STATE_STORAGE_LIBAVL_REDBLACK_TREE)
    requires_libavl=yes
elif test "x$state_storage" = "xlibredblack" ; then
    AC_DEFINE(FCS_STATE_STORAGE,FCS_STATE_STORAGE_LIBREDBLACK_TREE)
    requires_libredblack=yes
fi

if test "x$states_type" = "xindirect" ; then
    if   test "x$stack_storage" = "xglib_hash" ; then
        AC_DEFINE(FCS_STACK_STORAGE,FCS_STACK_STORAGE_GLIB_HASH)
        requires_glib=yes
    elif test "x$stack_storage" = "xglib_tree" ; then
        AC_DEFINE(FCS_STACK_STORAGE,FCS_STACK_STORAGE_GLIB_TREE)
        requires_glib=yes
    elif test "x$stack_storage" = "xinternal_hash" ; then
        AC_DEFINE(FCS_STACK_STORAGE,FCS_STACK_STORAGE_INTERNAL_HASH)
    elif test "x$stack_storage" = "xlibavl_avl" ; then
        AC_DEFINE(FCS_STACK_STORAGE,FCS_STACK_STORAGE_LIBAVL_AVL_TREE)
        requires_libavl=yes
    elif test "x$stack_storage" = "xlibavl_redblack" ; then
        AC_DEFINE(FCS_STACK_STORAGE,FCS_STACK_STORAGE_LIBAVL_REDBLACK_TREE)
        requires_libavl=yes
    elif test "x$stack_storage" = "xlibredblack" ; then
        AC_DEFINE(FCS_STACK_STORAGE,FCS_STACK_STORAGE_LIBREDBLACK_TREE)
        requires_libredblack=yes
    fi
fi

if test "x$requires_libavl" = "xyes" ; then
    AC_CHECK_LIB(avl, avl_create, [], [
        echo "Error! You need to have libavl around."
        exit -1
        ])
fi

if test "x$requires_libredblack" = "xyes" ; then
    AC_CHECK_LIB(redblack, rbsearch, [], [
        echo "Error! You need to have libredblack around."
        exit -1
        ])
fi

if test "x$requires_glib" = "xyes" ; then
    AC_CHECK_LIB(glib, g_hash_table_new)
    if test "x$ac_cv_lib_glib_g_hash_table_new" = "xno" ; then
        echo 
        echo "Error!"
        echo "You need to have glib around."
        exit -1
    fi

    
    if false ; then
        GTK_CFLAGS=`gtk-config --cflags`
        dnl Evil stuff to extract GLIB stuff from gtk-config output
        dnl (we want to make sure it matches with the gtk we're using)
        GTK_TEMP_CFLAGS=`echo $GTK_CFLAGS | sed 's/^\(-I[^ ]*\).*$/\1/'`
        if echo $GTK_TEMP_CFLAGS | grep 'glib/include$' > /dev/null; then
          GTK_TEMP_CFLAGS="$GTK_CFLAGS"
        else
          GTK_TEMP_CFLAGS=`echo $GTK_CFLAGS | sed 's/^-I[^ ]* \(.*\)$/\1/'`
        fi
        GLIB_CFLAGS=`echo $GTK_TEMP_CFLAGS | sed 's/^\(-I[^ ]*glib[^ ]*  *-I[^ ]*\).*/\1/'`
    fi
    GLIB_CFLAGS=`glib-config --cflags`
    # Append them to the compiler flags
    CFLAGS="$CFLAGS $GLIB_CFLAGS"
fi

dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_TYPE_SIZE_T
AC_C_INLINE

if test "x$ac_cv_inline" != "xno" ; then
    AC_DEFINE(HAVE_C_INLINE)
fi

dnl Checks for library functions.
AC_FUNC_MEMCMP
AC_TYPE_SIGNAL
AC_CHECK_FUNCS(strdup)

# Define COMPACT_STATES, DEBUG_STATES or INDIRECT_STACK_STATES
if   test "x$states_type" = "xcompact" ; then
    AC_DEFINE(COMPACT_STATES)
elif test "x$states_type" = "xdebug" ; then
    AC_DEFINE(DEBUG_STATES)
else
    AC_DEFINE(INDIRECT_STACK_STATES)
fi

if test "x$card_debug_pres" = "xyes" ; then
    AC_DEFINE(CARD_DEBUG_PRES)
fi

AC_DEFINE(PREV_STATES_SORT_MARGIN,32)
AC_DEFINE(PREV_STATES_GROW_BY,128)
AC_DEFINE(IA_STATE_PACKS_GROW_BY,32)
AC_DEFINE_UNQUOTED(MAX_NUM_FREECELLS,$max_num_freecells)
AC_DEFINE_UNQUOTED(MAX_NUM_STACKS,$max_num_stacks)
AC_DEFINE_UNQUOTED(MAX_NUM_INITIAL_CARDS_IN_A_STACK,$max_num_initial_cards_per_stack)
AC_DEFINE_UNQUOTED(MAX_NUM_DECKS,$max_num_decks)

AC_CONFIG_SUBDIRS([board_gen])

AC_OUTPUT([Makefile man/Makefile freecell-solver-config freecell-solver.spec prefix.h.proto Presets/Makefile Presets/presetrc.proto Presets/presets/Makefile], [chmod +x freecell-solver-config])

for I in prefix.h Presets/presetrc ; do
    cat $I.proto | sed s@'${prefix}'@"$prefix"@g > $I
done


