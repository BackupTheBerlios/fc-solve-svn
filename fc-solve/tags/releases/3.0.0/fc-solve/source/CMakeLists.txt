INCLUDE( "${CMAKE_CURRENT_SOURCE_DIR}/Common.cmake" )

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# This is the equivalent to perform a "make dist"/"make distdir" etc.
SET(CPACK_PACKAGE_NAME "freecell-solver")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Freecell Solver")
SET(CPACK_PACKAGE_VENDOR "Shlomi Fish")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.txt")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYING.txt")

# Process and extract the version number.
FILE( READ "ver.txt" VERSION)

CHOMP (VERSION)

STRING (REGEX MATCHALL "([0-9]+)" VERSION_DIGITS "${VERSION}")

LIST(GET VERSION_DIGITS 0 CPACK_PACKAGE_VERSION_MAJOR)
LIST(GET VERSION_DIGITS 1 CPACK_PACKAGE_VERSION_MINOR)
LIST(GET VERSION_DIGITS 2 CPACK_PACKAGE_VERSION_PATCH)

SET(CPACK_PACKAGE_INSTALL_DIRECTORY "${CPACK_PACKAGE_DESCRIPTION_SUMMARY} ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")

SET(CPACK_SOURCE_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")

SET (base_with_ver "freecell-solver-[0-9]+\\\\.[0-9]+\\\\.[0-9]+")

SET(CPACK_SOURCE_IGNORE_FILES
    "/_CPack_Packages/"
    "/CMakeFiles/"
    "/.deps/"
    "${base_with_ver}(-Source|-Linux)/"
    "${base_with_ver}.tar\\\\.(gz|bz2|Z|lzma|xz)$"
    "\\\\.o$"
    "~$"
    "/board_gen/(pi-make-microsoft-freecell-board|make-microsoft-freecell-board|make-gnome-freecell-board|make-aisleriot-freecell-board)$"
    "/(fc-solve|freecell-solver-range-parallel-solve|freecell-solver-fc-pro-range-solve|freecell-solver-multi-thread-solve|freecell-solver-fork-solve)$"
    "/lib(fcs|freecell-solver)\\\\.(a|la)$"
    "\\\\.so(\\\\.[0-9]+)*$"
    "/\\\\.svn/"
    "\\\\.(pdf|fo)$"
    "/t/t/.*\\\\.exe$"
    "/t/Presets"
    "/CMakeCache\\\\.txt$"
    "/Makefile$"
    "/CTestTestfile\\\\.cmake$"
    "/cmake_install\\\\.cmake$"
    "/CPackConfig\\\\.cmake$"
    "/CPackSourceConfig\\\\.cmake$"
    "/tags$"
    "/freecell-solver-config$"
    "/libfreecell-solver\\\\.pc$"
    "/([0-9]+)\\\\.board$"
    "/config\\\\.h$"
    "/install_manifest\\\\.txt$"
    "/t/card-test-(parse|render)\\\\.c$"
    "/Testing/"
    "ids-whitelist\\\\.txt"
)

IF(WIN32 AND NOT UNIX)
    # There is a bug in NSI that does not handle full unix paths properly. Make
    # sure there is at least one set of four (4) backlasshes.
    SET(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}\\\\dondorf-king.bmp")
    SET(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\fc-solve.exe")
    SET(CPACK_NSIS_HELP_LINK "http:\\\\\\\\fc-solve.berlios.de")
    SET(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\fc-solve.berlios.de")
    SET(CPACK_NSIS_DISPLAY_NAME "Freecell Solver")
    SET(CPACK_NSIS_CONTACT "shlomif@iglu.org.il")
    SET(CPACK_NSIS_MODIFY_PATH ON)
    # Setting for NSIS :
    SET(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}\\\\fc-solve.ico")
    SET(CPACK_NSIS_MUI_UNIICON ${CPACK_NSIS_MUI_ICON})
    SET(CPACK_PACKAGE_ICON ${CPACK_NSIS_MUI_ICON})
    SET(CPACK_NSIS_MODIFY_PATH "ON")
ELSE(WIN32 AND NOT UNIX)
  SET(CPACK_STRIP_FILES "fc-solve")
  SET(CPACK_SOURCE_STRIP_FILES "")
ENDIF(WIN32 AND NOT UNIX)

SET(CPACK_PACKAGE_EXECUTABLES
    "fc-solve" "Single-Game Solver"
)

### This is to set the RPATH correctly, so when installed under a prefix
### the executables will find the libraries.
### 
### See:
###
### http://www.cmake.org/Wiki/CMake_RPATH_handling
###
### (Taken from that wiki page)

# use, i.e. don't skip the full RPATH for the build tree
SET(CMAKE_SKIP_BUILD_RPATH  FALSE)

# when building, don't use the install RPATH already
# (but later on when installing)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) 

# the RPATH to be used when installing
SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)


SET (STATES_TYPE "INDIRECT_STACK_STATES" CACHE STRING 
    "States Type ('INDIRECT_STACK_STATES', 'COMPACT_STATES' or 'DEBUG_STATES'). No need to usually change.")
SET (IA_STATE_PACKS_GROW_BY 32 CACHE STRING "Amount to Grow State Packs By")
SET (MAX_NUM_FREECELLS 8 CACHE STRING "Maximal Number of Freecells")
SET (MAX_NUM_STACKS 10 CACHE STRING "Maximal Number of Stacks")
SET (MAX_NUM_INITIAL_CARDS_IN_A_STACK 8 CACHE STRING
    "Maximal Number of Initial Cards in a Stack")
SET (MAX_NUM_DECKS 2 CACHE STRING "Maximal Number of Decks (1 or 2)")
SET (MAX_NUM_BENCHMARK_THREADS 4 CACHE STRING "Maximal Number of Threads to Use When Benchmarking")

SET (FCS_STATE_STORAGE "FCS_STATE_STORAGE_INTERNAL_HASH" CACHE STRING "The State Storage Type")
SET (FCS_STACK_STORAGE "FCS_STACK_STORAGE_INTERNAL_HASH" CACHE STRING "The Stack Storage Type")

SET (FCS_FREECELL_ONLY "" CACHE BOOL "Configure Freecell Solver to only be able to solve Freecell (not recommended)")
SET (FCS_DISABLE_SIMPLE_SIMON "" CACHE BOOL "Exclude being able to solve Simple Simon from the Binary (not recommended)")
SET (FCS_WITHOUT_CARD_FLIPPING "" CACHE BOOL "Exclude the flipping of cards from the binary.")
SET (FCS_WITH_TEST_SUITE "" CACHE BOOL "Also build and run the test suite.")

SET (FCS_ENABLE_SECONDARY_HASH_VALUE "" 
    CACHE BOOL 
    "Enable the secondary hash value calculation and track-keeping. Seems to slow things down."
)

SET (FCS_WITH_CONTEXT_VARIABLE "1" 
    CACHE BOOL 
    "Enable the context (extra void *) as passed to the comparison functions, etc."
)

SET (FCS_INLINED_HASH_COMPARISON "1" 
    CACHE BOOL 
    "Inline the hash comparisons."
)

SET (FCS_USE_COMPACT_MOVE_TOKENS "" 
    CACHE BOOL 
    "Use more compact tokens for moves internally (makes things slower)"
)

SET (BUILD_STATIC_LIBRARY "1" CACHE BOOL "Whether to build the static library (which takes more time)" )

SET (CPU_ARCH "" CACHE STRING "A specific CPU architecture to pass to gcc")
SET (OPTIMIZATION_OMIT_FRAME_POINTER "" CACHE STRING "Use -fomit-frame-pointer with gcc (not recommended for debugging)")

SET (FCS_STATE_STORAGE_LIBAVL2_TREE_TYPE "avl" CACHE STRING "The libavl2 tree type used for the state storage. Ignored if not set to libavl2")
SET (FCS_STACK_STORAGE_LIBAVL2_TREE_TYPE "avl" CACHE STRING "The libavl2 tree type used for the stack storage. Ignored if not set to libavl2")
SET (LIBAVL2_SOURCE_DIR "/usr/src/avl-2.0.3" CACHE STRING "The location of the libavl2 source tree (from which files are copied)")

IF (NOT (STATES_TYPE MATCHES "^(INDIRECT_STACK_STATES|COMPACT_STATES|DEBUG_STATES)$"))
    MESSAGE(FATAL_ERROR "STATES_TYPE should be ('INDIRECT_STACK_STATES', 'COMPACT_STATES' or 'DEBUG_STATES')")
ENDIF(NOT (STATES_TYPE MATCHES "^(INDIRECT_STACK_STATES|COMPACT_STATES|DEBUG_STATES)$"))

SET (${STATES_TYPE} 1)

SET (FREECELL_SOLVER_LIB_MODULES alloc.c app_str.c card.c check_and_add_state.c cmd_line.c freecell.c instance.c lib.c move.c move_funcs_maps.c move_funcs_order.c preset.c scans.c simpsim.c split_cmd_line.c state.c)

IF (FCS_FREECELL_ONLY)
    LIST (REMOVE_ITEM FREECELL_SOLVER_LIB_MODULES preset.c)
    SET (FCS_DISABLE_SIMPLE_SIMON 1)
ENDIF (FCS_FREECELL_ONLY)

IF (FCS_DISABLE_SIMPLE_SIMON)
    LIST (REMOVE_ITEM FREECELL_SOLVER_LIB_MODULES simpsim.c)
ENDIF (FCS_DISABLE_SIMPLE_SIMON)

# Add the fcs_hash.c if (and only if) it is being used.
# 
IF ((${FCS_STATE_STORAGE} STREQUAL "FCS_STATE_STORAGE_INTERNAL_HASH") OR
    (${FCS_STACK_STORAGE} STREQUAL "FCS_STACK_STORAGE_INTERNAL_HASH"))

    LIST(APPEND FREECELL_SOLVER_LIB_MODULES fcs_hash.c)

ENDIF ((${FCS_STATE_STORAGE} STREQUAL "FCS_STATE_STORAGE_INTERNAL_HASH") OR
    (${FCS_STACK_STORAGE} STREQUAL "FCS_STACK_STORAGE_INTERNAL_HASH"))

# Add fcs_dm.c if (and only if) it is being used.
# 
IF (${FCS_STATE_STORAGE} STREQUAL "FCS_STATE_STORAGE_INDIRECT")
    LIST(APPEND FREECELL_SOLVER_LIB_MODULES fcs_dm.c)
ENDIF (${FCS_STATE_STORAGE} STREQUAL "FCS_STATE_STORAGE_INDIRECT")

# Search for libredblack if appropriate.
IF ((${FCS_STATE_STORAGE} STREQUAL "FCS_STATE_STORAGE_LIBREDBLACK_TREE") OR
    (${FCS_STACK_STORAGE} STREQUAL "FCS_STACK_STORAGE_LIBREDBLACK_TREE"))

    FIND_LIBRARY(LIBREDBLACK_LIB redblack)

ENDIF ((${FCS_STATE_STORAGE} STREQUAL "FCS_STATE_STORAGE_LIBREDBLACK_TREE") OR
    (${FCS_STACK_STORAGE} STREQUAL "FCS_STACK_STORAGE_LIBREDBLACK_TREE"))

# Search for Judy ( http://judy.sourceforge.net/ ) if appropriate.
IF ((${FCS_STATE_STORAGE} STREQUAL "FCS_STATE_STORAGE_JUDY") OR
    (${FCS_STACK_STORAGE} STREQUAL "FCS_STACK_STORAGE_JUDY"))

    FIND_LIBRARY(LIBJUDY_LIB Judy)

ENDIF ((${FCS_STATE_STORAGE} STREQUAL "FCS_STATE_STORAGE_JUDY") OR
       (${FCS_STACK_STORAGE} STREQUAL "FCS_STACK_STORAGE_JUDY"))

SET (LIBAVL2_COPIED_MODULES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libavl2")

# Initialize to the empty list - it may or may not be populated.
SET (LIBAVL2_TREE_TYPES )

MACRO(ADD_TREE_TYPE TREE_TYPE)
    LIST(APPEND LIBAVL2_TREE_TYPES ${TREE_TYPE})
    LIST(REMOVE_DUPLICATES LIBAVL2_TREE_TYPES)
ENDMACRO(ADD_TREE_TYPE TREE_TYPE)

IF (${FCS_STATE_STORAGE} STREQUAL "FCS_STATE_STORAGE_LIBAVL2_TREE")
    SET (TREE_TYPE "${FCS_STATE_STORAGE_LIBAVL2_TREE_TYPE}")
    ADD_TREE_TYPE("${TREE_TYPE}")
    FILE (MAKE_DIRECTORY "${LIBAVL2_COPIED_MODULES_DIR}")
    INCLUDE_DIRECTORIES(BEFORE "${LIBAVL2_COPIED_MODULES_DIR}")
    SET (MPROT "FC_SOLVE__STATE_STORAGE_H")
    SET (PREFIXO "fcs_libavl2_states_tree")
    FILE (WRITE "${LIBAVL2_COPIED_MODULES_DIR}/fcs_libavl2_state_storage.h"
"
#ifndef ${MPROT}
#define ${MPROT}

#include \"${TREE_TYPE}.h\"

typedef struct ${TREE_TYPE}_table ${PREFIXO}_table_t;
#define ${PREFIXO}_insert(a,b) ${TREE_TYPE}_insert((a),(b))
#define ${PREFIXO}_create(a,b,c) ${TREE_TYPE}_create((a),(b),(c))
#define ${PREFIXO}_destroy(a,b) ${TREE_TYPE}_destroy((a),(b))

#endif /* ${MPROT} */
"
)

ENDIF (${FCS_STATE_STORAGE} STREQUAL "FCS_STATE_STORAGE_LIBAVL2_TREE")

IF (${FCS_STACK_STORAGE} STREQUAL "FCS_STACK_STORAGE_LIBAVL2_TREE")
    SET (TREE_TYPE "${FCS_STACK_STORAGE_LIBAVL2_TREE_TYPE}")
    ADD_TREE_TYPE("${TREE_TYPE}")
    FILE (MAKE_DIRECTORY "${LIBAVL2_COPIED_MODULES_DIR}")
    SET (MPROT "FC_SOLVE__STACK_STORAGE_H")
    SET (PREFIXO "fcs_libavl2_stacks_tree")
    FILE (WRITE "${LIBAVL2_COPIED_MODULES_DIR}/fcs_libavl2_stack_storage.h"
"
#ifndef ${MPROT}
#define ${MPROT}

#include \"${TREE_TYPE}.h\"

typedef struct ${TREE_TYPE}_table ${PREFIXO}_table_t;
#define ${PREFIXO}_insert(a,b) ${TREE_TYPE}_insert((a),(b))
#define ${PREFIXO}_create(a,b,c) ${TREE_TYPE}_create((a),(b),(c))
#define ${PREFIXO}_destroy(a,b) ${TREE_TYPE}_destroy((a),(b))

#endif /* ${MPROT} */
"
    )

ENDIF (${FCS_STACK_STORAGE} STREQUAL "FCS_STACK_STORAGE_LIBAVL2_TREE")

IF (LIBAVL2_TREE_TYPES)
    INCLUDE_DIRECTORIES(BEFORE "${LIBAVL2_COPIED_MODULES_DIR}")
    FOREACH (TREE_TYPE ${LIBAVL2_TREE_TYPES})
        SET (C_FN "${TREE_TYPE}.c")
        SET (H_FN "${TREE_TYPE}.h")
        CONFIGURE_FILE ("${LIBAVL2_SOURCE_DIR}/${C_FN}" 
            "${LIBAVL2_COPIED_MODULES_DIR}/${C_FN}"
            COPYONLY
        )
        CONFIGURE_FILE ("${LIBAVL2_SOURCE_DIR}/${H_FN}" 
            "${LIBAVL2_COPIED_MODULES_DIR}/${H_FN}"
            COPYONLY
        )
        LIST(APPEND FREECELL_SOLVER_LIB_MODULES "${LIBAVL2_COPIED_MODULES_DIR}/${C_FN}")
    ENDFOREACH (TREE_TYPE ${LIBAVL2_TREE_TYPES})
ENDIF (LIBAVL2_TREE_TYPES)

SET (MY_LINK_FLAGS "")
SET (MY_TO_PROFILE "")
IF (CMAKE_BUILD_TYPE STREQUAL profile)
    SET (MY_TO_PROFILE "1")
    SET (CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_DEBUG} -pg")
    SET (MY_LINK_FLAGS "-pg -static-libgcc")
    SET (BUILD_STATIC_LIBRARY "1")
    SET (MY_TARGET_LINK_LIBS "freecell-solver-static" "m_p" "c_p")
ELSE (CMAKE_BUILD_TYPE STREQUAL profile)
    SET (MY_TARGET_LINK_LIBS "freecell-solver")
ENDIF (CMAKE_BUILD_TYPE STREQUAL profile)


INCLUDE(CPack)

include(CheckFunctionExists)
INCLUDE(CheckCCompilerFlag)
INCLUDE(FindThreads)

ADD_SUBDIRECTORY ("board_gen")
ADD_SUBDIRECTORY ("man")
ADD_SUBDIRECTORY ("Presets")
ADD_SUBDIRECTORY ("t")

CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(COMPILER_FLAGS_TO_CHECK 
    "-Wall" "-Werror=implicit-function-declaration" "-fvisibility=hidden"
)

IF (CPU_ARCH)
    LIST(APPEND COMPILER_FLAGS_TO_CHECK "-march=${CPU_ARCH}")
ENDIF(CPU_ARCH)

IF (OPTIMIZATION_OMIT_FRAME_POINTER)
    LIST(APPEND COMPILER_FLAGS_TO_CHECK "-fomit-frame-pointer")
ENDIF(OPTIMIZATION_OMIT_FRAME_POINTER)

IF (CMAKE_BUILD_TYPE STREQUAL debug)
    LIST(APPEND COMPILER_FLAGS_TO_CHECK "-DFCS_COMPILE_DEBUG_FUNCTIONS=1")
ENDIF (CMAKE_BUILD_TYPE STREQUAL debug)

SET (IDX 1)
FOREACH (CFLAG_TO_CHECK ${COMPILER_FLAGS_TO_CHECK})
    SET (FLAG_EXISTS_VAR "FLAG_EXISTS_${IDX}")
    MATH (EXPR IDX "${IDX} + 1")
    CHECK_C_COMPILER_FLAG("${CFLAG_TO_CHECK}" ${FLAG_EXISTS_VAR})
    IF (${FLAG_EXISTS_VAR})
        ADD_DEFINITIONS(${CFLAG_TO_CHECK})
    ENDIF (${FLAG_EXISTS_VAR})
ENDFOREACH(CFLAG_TO_CHECK)

# So it can find config.h
INCLUDE_DIRECTORIES(BEFORE ${CMAKE_CURRENT_BINARY_DIR})

SET (FREECELL_SOLVER_LIBS)

ADD_LIBRARY (freecell-solver
    SHARED
    ${FREECELL_SOLVER_LIB_MODULES}
    )

LIST (APPEND FREECELL_SOLVER_LIBS "freecell-solver")
IF (BUILD_STATIC_LIBRARY)
    ADD_LIBRARY (freecell-solver-static
        STATIC
        ${FREECELL_SOLVER_LIB_MODULES}
    )
    LIST (APPEND FREECELL_SOLVER_LIBS "freecell-solver-static")

    SET_TARGET_PROPERTIES(
        freecell-solver-static 
        PROPERTIES OUTPUT_NAME "freecell-solver"
    )
    SET_TARGET_PROPERTIES(
        ${FREECELL_SOLVER_LIBS}
        PROPERTIES CLEAN_DIRECT_OUTPUT 1
    )
ENDIF (BUILD_STATIC_LIBRARY)

ADD_LIBRARY (fcs_gen_ms_freecell_boards
    SHARED
    gen_boards_lib.c
    )

SET_TARGET_PROPERTIES(freecell-solver
    PROPERTIES VERSION 0.5.0 SOVERSION 0
    )

IF (UNIX)
    SET(MATH_LIB "m")
ELSE(UNIX)
    SET(MATH_LIB )
ENDIF(UNIX)

SET(LIBTCMALLOC_LIB_LIST)

IF (NOT CMAKE_BUILD_TYPE STREQUAL debug)

    # Optionally link against Google's TCMalloc if it's available:
    # http://goog-perftools.sourceforge.net/
    # This gives better performance for the threaded programs.
    FIND_LIBRARY(LIBTCMALLOC_LIB tcmalloc)

    IF(LIBTCMALLOC_LIB STREQUAL "LIBTCMALLOC_LIB-NOTFOUND")
        # Do nothing.
    ELSE(LIBTCMALLOC_LIB STREQUAL "LIBTCMALLOC_LIB-NOTFOUND")
        # Cancelling for now to see if it helps with the valgrind problem.
        # TODO : restore
        SET(LIBTCMALLOC_LIB_LIST ${LIBTCMALLOC_LIB})
    ENDIF(LIBTCMALLOC_LIB STREQUAL "LIBTCMALLOC_LIB-NOTFOUND")
    
ENDIF (NOT CMAKE_BUILD_TYPE STREQUAL debug)


TARGET_LINK_LIBRARIES (freecell-solver 
    ${MATH_LIB} ${LIBTCMALLOC_LIB_LIST} ${LIBREDBLACK_LIB} ${LIBJUDY_LIB}
    )

SET(FREECELL_SOLVER_EXECUTABLES )
MACRO(FCS_ADD_EXEC_NO_INSTALL target)
    SET(modules ${ARGV})
    LIST(REMOVE_AT modules 0)
    ADD_EXECUTABLE(${target} ${modules})
    LIST(APPEND FREECELL_SOLVER_EXECUTABLES ${target})
    TARGET_LINK_LIBRARIES (${target} ${MY_TARGET_LINK_LIBS})
ENDMACRO(FCS_ADD_EXEC_NO_INSTALL target)

MACRO(FCS_ADD_EXEC target)
    FCS_ADD_EXEC_NO_INSTALL(${ARGV})
    INSTALL (TARGETS ${target} DESTINATION "bin")
ENDMACRO(FCS_ADD_EXEC)


FCS_ADD_EXEC(fc-solve main.c)
FCS_ADD_EXEC(freecell-solver-range-parallel-solve test_multi_parallel.c)
FCS_ADD_EXEC(freecell-solver-fc-pro-range-solve fc_pro_range_solver.c fc_pro_iface.c)

FCS_ADD_EXEC_NO_INSTALL(
    temp-flair-solver temp-fc_pro_range_solver_with_flair_support.c
    fc_pro_iface.c
)

IF (CMAKE_USE_PTHREADS_INIT)
    FCS_ADD_EXEC(freecell-solver-multi-thread-solve threaded_range_solver.c)
    TARGET_LINK_LIBRARIES(freecell-solver-multi-thread-solve "pthread")
ENDIF (CMAKE_USE_PTHREADS_INIT)

IF (UNIX)
    FCS_ADD_EXEC_NO_INSTALL(
        freecell-solver-fork-solve "forking_range_solver.c"
    )
ENDIF (UNIX)

IF (MY_LINK_FLAGS)
    SET_TARGET_PROPERTIES(
        ${FREECELL_SOLVER_LIBS} 
        ${FREECELL_SOLVER_EXECUTABLES}
        PROPERTIES LINK_FLAGS "${MY_LINK_FLAGS}"
    )
ENDIF (MY_LINK_FLAGS)

CHECK_FUNCTION_EXISTS(pow HAVE_POW)

SET(AUTOGENERATED_CONFIG_H "config.h was auto-generated from config.h.in . Do not modify directly")

INCLUDE (CheckTypeSize)
CHECK_TYPE_SIZE("int" INT_SIZE_IN_BYTES)

MATH(EXPR INT_SIZE_IN_BITS "8 * ${INT_SIZE_IN_BYTES}")

SET(TEMP_SIZE 1)
SET(FCS_INT_BIT_SIZE_LOG2 0)

WHILE ( NOT ("${TEMP_SIZE}" STREQUAL "${INT_SIZE_IN_BITS}") )

    MATH(EXPR TEMP2 "${TEMP_SIZE} << 1")
    SET(TEMP_SIZE "${TEMP2}")

    MATH(EXPR TEMP2 "${FCS_INT_BIT_SIZE_LOG2} + 1")
    SET(FCS_INT_BIT_SIZE_LOG2 "${TEMP2}")

ENDWHILE ( NOT ("${TEMP_SIZE}" STREQUAL "${INT_SIZE_IN_BITS}") )

# Inspired from /usr/share/autoconf/autoconf/c.m4
FOREACH(KEYWORD "inline" "__inline__" "__inline")
   IF(NOT DEFINED HAVE_C_INLINE)
     TRY_COMPILE(C_HAS_${KEYWORD} "${CMAKE_CURRENT_BINARY_DIR}"
       "${CMAKE_CURRENT_SOURCE_DIR}/test_inline.c"
       COMPILE_DEFINITIONS "-Dinline=${KEYWORD}")
     IF(C_HAS_${KEYWORD})
       SET(HAVE_C_INLINE TRUE)
       SET(FCS_INLINE_KEYWORD "${KEYWORD}")
     ENDIF(C_HAS_${KEYWORD})
   ENDIF(NOT DEFINED HAVE_C_INLINE)
ENDFOREACH(KEYWORD)

CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/config.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
    )

CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/prefix.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/prefix.h
    )

CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/${CPACK_PACKAGE_NAME}.spec.in
    ${CMAKE_CURRENT_SOURCE_DIR}/${CPACK_PACKAGE_NAME}.spec
    )

CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/${CPACK_PACKAGE_NAME}-config.in
    ${CMAKE_CURRENT_BINARY_DIR}/${CPACK_PACKAGE_NAME}-config
    )

CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/lib${CPACK_PACKAGE_NAME}.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/lib${CPACK_PACKAGE_NAME}.pc
    @ONLY
    )

INSTALL(
    TARGETS ${FREECELL_SOLVER_LIBS}
    DESTINATION "lib"
)

IF (WIN32 AND NOT UNIX)
    # This is so on Windows, the .dll's will be installed in the bin/ 
    # directory as well where the Freecell Solver command-line utilities
    # will be able to find them.

    INSTALL(
        TARGETS "freecell-solver"
        DESTINATION "bin"
    )
ENDIF (WIN32 AND NOT UNIX)

INSTALL(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/${CPACK_PACKAGE_NAME}-config"
    DESTINATION "bin"
)

RUN_POD2MAN(
    "${CMAKE_CURRENT_SOURCE_DIR}/fc-solve.pod"
    "fc-solve.6"
    "6"
    "Freecell Solver"
    "Freecell Solver ${VERSION}"
)

INSTALL_MAN ("${CMAKE_CURRENT_BINARY_DIR}/fc-solve.6" 6)

INSTALL(
    FILES
        ${docs_to_install}
        "README.win32.txt"
    DESTINATION
        "share/doc/freecell-solver/"
)

INSTALL(
    FILES
        "fcs_cl.h"
        "fcs_enums.h"
        "fcs_move.h"
        "fcs_user.h"
    DESTINATION
        "include/freecell-solver"
)


INSTALL(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/lib${CPACK_PACKAGE_NAME}.pc"
    DESTINATION 
        "lib/pkgconfig"
)

# Rebuild config.h if ver.txt has changed.
ADD_CUSTOM_COMMAND(
    OUTPUT "config.h.in"
    DEPENDS "ver.txt"
    COMMAND "touch"
    ARGS "config.h.in"
)

SET (BOARDS "")

MACRO(GEN_BOARD idx)
    SET(board "${idx}.board")
    ADD_CUSTOM_COMMAND(
        OUTPUT ${board}
        COMMAND "python"
        ARGS "board_gen/make_pysol_freecell_board.py" ${idx} ">" ${board}
    )
    SET(BOARDS ${BOARDS} ${board})
ENDMACRO(GEN_BOARD idx)

FOREACH(idx 24 1941)
    GEN_BOARD(${idx})
ENDFOREACH(idx)

ADD_CUSTOM_TARGET(
    boards
    DEPENDS ${BOARDS}
)

FIND_PACKAGE(Asciidoc)

SET (_docfiles "AUTHORS.txt" "COPYING.txt" "HACKING.txt" "INSTALL.txt" 
    "NEWS.txt" "README.txt" "TODO.txt" "USAGE.txt" 
)

SET (docs_to_install)
FOREACH(_file ${_docfiles})
    GET_FILENAME_COMPONENT(_file_we ${_file} NAME_WE)
    SET(_full_file "${CMAKE_CURRENT_BINARY_DIR}/${_file_we}")
    LIST(APPEND docs_to_install ${_full_file})
ENDFOREACH(_file)

IF(ASCIIDOC_FOUND)

    SET (_pdf_targets)

    FOREACH(_file ${_docfiles})
        GET_FILENAME_COMPONENT(_file_we ${_file} NAME_WE)
        SET(_in "${_file_we}")
        SET(_html_out "${CMAKE_CURRENT_SOURCE_DIR}/${_file_we}.html")
        SET(_full_file "${CMAKE_CURRENT_SOURCE_DIR}/${_file}")
        SET(_docbook_out "${CMAKE_CURRENT_SOURCE_DIR}/${_file_we}.xml")
        # MESSAGE(STATUS "_in == <<${_in}>> _html_out == <<${_html_out}>>")

        # -a toc 
        ADD_CUSTOM_COMMAND(
            OUTPUT "${_html_out}"
            COMMAND ${ASCIIDOC_EXECUTABLE} 
                -o ${_html_out} "${_full_file}"
            DEPENDS "${_full_file}"
            COMMENT "Asciidoc ${_in}"
            )


        ADD_CUSTOM_COMMAND(
            OUTPUT "${_docbook_out}"
            COMMAND ${ASCIIDOC_EXECUTABLE} 
                --backend=docbook -o ${_docbook_out} "${_full_file}"
            DEPENDS "${_full_file}"
            COMMENT "Asciidoc->DocBook ${_in}"
            )

        SET (_pdf "${_file_we}.pdf")

        SET (target "${_file_we}_build")

        ADD_CUSTOM_COMMAND(
            OUTPUT "${_pdf}"
            COMMAND docmake -v --make -o ${_pdf} pdf ${_docbook_out}
            DEPENDS ${_docbook_out}
            COMMENT "docmake to PDF"
        )

        ADD_CUSTOM_COMMAND(
            OUTPUT ${_file_we}
            COMMAND cp -f "${_full_file}" ${_file_we}
            DEPENDS "${_file_we}.txt"
            COMMENT "copy AsciiDoc to non-\".txt\" file"
        )
    
        ADD_CUSTOM_TARGET(${target} ALL echo -n
            DEPENDS "${_html_out}" "${_docbook_out}" "${_file_we}"
        )

        ADD_CUSTOM_TARGET(${_in}_pdf echo -n
            DEPENDS "${_pdf}"
        )

        LIST(APPEND _pdf_targets ${_in}_pdf)

    ENDFOREACH(_file)

    # MESSAGE ("PDF_TARGETS == ${_pdf_targets}")

    SET (_master_pdf_target "pdfs")
    ADD_CUSTOM_TARGET("${_master_pdf_target}" echo -n)
    ADD_DEPENDENCIES("${_master_pdf_target}" ${_pdf_targets})

ENDIF(ASCIIDOC_FOUND)

IF (FCS_WITH_TEST_SUITE)
    
    ADD_CUSTOM_TARGET(
        "test"
        "perl" "run-tests.pl"
    )

    ADD_DEPENDENCIES(
        "test"
        "all"
    )

ENDIF(FCS_WITH_TEST_SUITE)

ADD_CUSTOM_TARGET(
    "bench" bash scripts/time-threads-num.bash -s 2 "${MAX_NUM_BENCHMARK_THREADS}"
    COMMAND perl scripts/time-fcs.pl dump "DUMPS/*"
)

