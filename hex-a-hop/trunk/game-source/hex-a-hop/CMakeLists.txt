# This is the equivalent to perform a "make dist"/"make distdir" etc.
SET(CPACK_PACKAGE_NAME "hex-a-hop")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Hex-a-hop")
SET(CPACK_PACKAGE_VENDOR "Shlomi Fish")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/Copying")

# Process and extract the version number.
FILE( READ "ver.txt" VERSION)

CHOMP (VERSION)

STRING (REGEX MATCHALL "([0-9]+)" VERSION_DIGITS "${VERSION}")

LIST(GET VERSION_DIGITS 0 CPACK_PACKAGE_VERSION_MAJOR)
LIST(GET VERSION_DIGITS 1 CPACK_PACKAGE_VERSION_MINOR)
LIST(GET VERSION_DIGITS 2 CPACK_PACKAGE_VERSION_PATCH)

SET(CPACK_PACKAGE_INSTALL_DIRECTORY "CMake ${CMake_VERSION_MAJOR}.${CMake_VERSION_MINOR}")

SET(CPACK_SOURCE_IGNORE_FILES
    "/_CPack_Packages/"
    "/CMakeFiles/"
    "hex-a-hop-[0-9]+\\\\.[0-9]+\\\\.[0-9]+-(Source|Linux)(/|\\\\.(sh|tar\\\\.(gz|bz2|Z|lzma))$)"
    "\\\\.o$"
    "~$"
    "/hex-a-hop$"
    "\\\\.so$"
    "/.svn/"
    "/t/t/.*\\\\.exe$"
    "/CMakeCache.txt$"
    "/Makefile$"
    "/CTestTestfile.cmake$"
    "/CPackConfig.cmake$"
)


IF(WIN32 AND NOT UNIX)
  # There is a bug in NSI that does not handle full unix paths properly. Make
  # sure there is at least one set of four (4) backlasshes.
  SET(CPACK_PACKAGE_ICON "${CMake_SOURCE_DIR}/Utilities/Release\\\\InstallIcon.bmp")
  SET(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\MyExecutable.exe")
  SET(CPACK_NSIS_DISPLAY_NAME "${CPACK_PACKAGE_INSTALL_DIRECTORY} My Famous Project")
  SET(CPACK_NSIS_HELP_LINK "http:\\\\\\\\fc-solve.berlios.de")
  SET(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\fc-solve.berlios.de")
  SET(CPACK_NSIS_CONTACT "shlomif@iglu.org.il")
  SET(CPACK_NSIS_MODIFY_PATH ON)
ELSE(WIN32 AND NOT UNIX)
  SET(CPACK_STRIP_FILES "hex-a-hop")
  SET(CPACK_SOURCE_STRIP_FILES "")
ENDIF(WIN32 AND NOT UNIX)

SET(CPACK_PACKAGE_EXECUTABLES 
    "hex-a-hop" "Hex-tile-based Puzzle Game"
)

INCLUDE(CPack)

CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

Project ( Hex_a_hop )

set (
   SOURCES
    gfx.cpp
    hex_puzzzle.cpp
)

# REQUIRED does not work in CMake <=2.4.6 for SDL
FIND_PACKAGE ( SDL REQUIRED )

# Workaround for the non-working REQUIRED flag
IF ( NOT SDL_FOUND )
   MESSAGE ( FATAL_ERROR "SDL not found!" )
ENDIF ( NOT SDL_FOUND )

LINK_LIBRARIES (
   ${SDL_LIBRARY}
   SDLmain # Sadly not included in SDL_LIBRARY variable
)

ADD_EXECUTABLE (
   "hex-a-hop"
   WIN32 # Only if you don't want the DOS prompt to appear in the background in Windows
   MACOSX_BUNDLE
   ${SOURCES} # We could've listed the source files here directly instead of using a variable to store them
)

CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/config.h.in
    ${CMAKE_CURRENT_SOURCE_DIR}/config.h
    )

INSTALL(
    TARGETS "hex-a-hop"
    DESTINATION "bin"
)

INSTALL(
    FILES
        "Copying"
        "README"
    DESTINATION
        "share/doc/hex-a-hop-${VERSION}/"
)

# Rebuild config.h if ver.txt has changed.
ADD_CUSTOM_COMMAND(
    OUTPUT "config.h.in"
    DEPENDS "ver.txt"
    COMMAND "touch"
    ARGS "config.h.in"
    )
