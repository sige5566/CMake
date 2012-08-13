# - Try to find M&S HLA RTI libraries
# This module finds if any HLA RTI is installed and locates the standard RTI
# include files and libraries.
#
# RTI is a simulation infrastructure standardized by IEEE and SISO. It has a
# well defined C++ API that assures that simulation applications are
# independent on a particular RTI implementation.
#  http://en.wikipedia.org/wiki/Run-Time_Infrastructure_(simulation)
#
# This code sets the following variables:
#  RTI_INCLUDE_DIR = the directory where RTI includes file are found
#  RTI_LIBRARIES = The libraries to link against to use RTI
#  RTI_DEFINITIONS = -DRTI_USES_STD_FSTREAM
#  RTI_FOUND = Set to FALSE if any HLA RTI was not found
#
# Report problems to <certi-devel@nongnu.org>

#=============================================================================
# Copyright 2008-2009 Kitware, Inc.
# Copyright 2008 Petr Gotthard <gotthard@honeywell.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

macro(RTI_MESSAGE_QUIETLY QUIET TYPE MSG)
  if(NOT ${QUIET})
    message(${TYPE} "${MSG}")
  endif(NOT ${QUIET})
endmacro(RTI_MESSAGE_QUIETLY QUIET TYPE MSG)

# Detect the CERTI installation, http://www.cert.fr/CERTI
if ("$ENV{CERTI_HOME}" STRGREATER "")
  file(TO_CMAKE_PATH "$ENV{CERTI_HOME}" CERTI_HOME)
  RTI_MESSAGE_QUIETLY(RTI_FIND_QUIETLY STATUS "Using environment defined CERTI_HOME: ${CERTI_HOME}")
endif ("$ENV{CERTI_HOME}" STRGREATER "")

set(RTI_DEFINITIONS "-DRTI_USES_STD_FSTREAM")

# Detect the MAK Technologies RTI installation, http://www.mak.com/products/rti.php
# note: the following list is ordered to find the most recent version first
set(RTI_POSSIBLE_DIRS
  ${CERTI_HOME}
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\MAK Technologies\\MAK RTI 3.2 MSVC++ 8.0;Location]"
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\MAK RTI 3.2-win32-msvc++8.0;InstallLocation]"
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\MAK Technologies\\MAK RTI 2.2;Location]"
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\MAK RTI 2.2;InstallLocation]")

set(RTI_OLD_FIND_LIBRARY_PREFIXES "${CMAKE_FIND_LIBRARY_PREFIXES}")
# The MAK RTI has the "lib" prefix even on Windows.
set(CMAKE_FIND_LIBRARY_PREFIXES "lib" "")

find_library(RTI_LIBRARY
  NAMES RTI RTI-NG
  PATHS ${RTI_POSSIBLE_DIRS}
  PATH_SUFFIXES lib
  DOC "The RTI Library")

if (RTI_LIBRARY)
  set(RTI_LIBRARIES ${RTI_LIBRARY})
  RTI_MESSAGE_QUIETLY(RTI_FIND_QUIETLY STATUS "RTI library found: ${RTI_LIBRARY}")
else (RTI_LIBRARY)
  RTI_MESSAGE_QUIETLY(RTI_FIND_QUIETLY STATUS "RTI library NOT found")
endif (RTI_LIBRARY)

find_library(RTI_FEDTIME_LIBRARY
  NAMES FedTime
  PATHS ${RTI_POSSIBLE_DIRS}
  PATH_SUFFIXES lib
  DOC "The FedTime Library")

if (RTI_FEDTIME_LIBRARY)
  set(RTI_LIBRARIES ${RTI_LIBRARIES} ${RTI_FEDTIME_LIBRARY})
  RTI_MESSAGE_QUIETLY(RTI_FIND_QUIETLY STATUS "RTI FedTime found: ${RTI_FEDTIME_LIBRARY}")
endif (RTI_FEDTIME_LIBRARY)

find_path(RTI_INCLUDE_DIR
  NAMES RTI.hh
  PATHS ${RTI_POSSIBLE_DIRS}
  PATH_SUFFIXES include
  DOC "The RTI Include Files")

if (RTI_INCLUDE_DIR)
  RTI_MESSAGE_QUIETLY(RTI_FIND_QUIETLY STATUS "RTI headers found: ${RTI_INCLUDE_DIR}")
else (RTI_INCLUDE_DIR)
  RTI_MESSAGE_QUIETLY(RTI_FIND_QUIETLY STATUS "RTI headers NOT found")
endif (RTI_INCLUDE_DIR)

# Set the modified system variables back to the original value.
set(CMAKE_FIND_LIBRARY_PREFIXES "${RTI_OLD_FIND_LIBRARY_PREFIXES}")

include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(RTI DEFAULT_MSG
  RTI_LIBRARY RTI_INCLUDE_DIR)

# $Id$
