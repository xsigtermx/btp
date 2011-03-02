#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_INIT(btptest, 0.0.0, chris@dod.net)
AC_CONFIG_SRCDIR([src/damage_test.c])
AC_CONFIG_HEADER([config.h])
AM_INIT_AUTOMAKE

# Checks for programs.
AC_PROG_CC
AC_PROG_LIBTOOL

# Checks for libraries.
AM_WITH_DMALLOC

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h dmalloc.h math.h unistd.h string.h time.h])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_CHECK_LIB(m, pow)

AC_CONFIG_FILES([Makefile  
                 src/Makefile])
AC_OUTPUT
