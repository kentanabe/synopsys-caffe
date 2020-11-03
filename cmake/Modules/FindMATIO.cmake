# Try to find the LMDB libraries and headers
#  MATIO_FOUND - system has MATIO lib
#  MATIO_INCLUDE_DIR - the MATIO include directory
#  MATIO_LIBRARIES - Libraries needed to use MATIO

# FindCWD based on FindGMP by:
# Copyright (c) 2006, Laurent Montel, <montel@kde.org>
#
# Redistribution and use is allowed according to the terms of the BSD license.

# Adapted from FindCWD by:
# Copyright 2013 Conrad Steenberg <conrad.steenberg@gmail.com>
# Aug 31, 2013

if(MSVC)
  find_package(MATIO NO_MODULE)
else()
  find_path(MATIO_INCLUDE_DIR NAMES  matio.h PATHS "$ENV{MATIO_DIR}/include")
  find_library(MATIO_LIBRARIES NAMES matio   PATHS "$ENV{MATIO_DIR}/lib" )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MATIO DEFAULT_MSG MATIO_INCLUDE_DIR MATIO_LIBRARIES)

if(MATIO_FOUND)
  message(STATUS "Found matio    (include: ${MATIO_INCLUDE_DIR}, library: ${MATIO_LIBRARIES})")
  mark_as_advanced(MATIO_INCLUDE_DIR MATIO_LIBRARIES)

  caffe_parse_header(${MATIO_INCLUDE_DIR}/matio.h
                     MATIO_VERSION_LINES MDB_VERSION_MAJOR MDB_VERSION_MINOR MDB_VERSION_PATCH)
  set(MATIO_VERSION "${MDB_VERSION_MAJOR}.${MDB_VERSION_MINOR}.${MDB_VERSION_PATCH}")
endif()
