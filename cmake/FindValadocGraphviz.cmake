#- Find the graphviz library (not the executable)
# Sets the following variables:
#  LIBGRAPHVIZ_FOUND
#  LIBGRAPHVIZ_INCLUDE_DIR
#  LIBGRAPHVIZ_LIBRARIES
#  LIBGRAPHVIZ_VERSION
#

# find include path
find_path(LIBGRAPHVIZ_INCLUDE_DIR graphviz/graphviz_version.h)

# fnd the libraries
find_library(LIBGRAPHVIZ_GVC_LIBRARY gvc)
find_library(LIBGRAPHVIZ_GRAPH_LIBRARY graph)
find_library(LIBGRAPHVIZ_CDT_LIBRARY cdt)

# parse version
if(LIBGRAPHVIZ_INCLUDE_DIR)
  file(READ "${LIBGRAPHVIZ_INCLUDE_DIR}/graphviz/graphviz_version.h" _gv_version_h)
  string(REGEX REPLACE ".*#define[ \t]+VERSION[ \t]+\"(.+)\".*" "\\1"
    LIBGRAPHVIZ_VERSION "${_gv_version_h}")
  if(NOT LIBGRAPHVIZ_VERSION)
    message(FATAL_ERROR "Failed to parse version from"
      "${LIBGRAPHVIZ_INCLUDE_DIR}/graphviz/graphviz_version.h")
  endif()
endif()

# check package version
set(LIBGRAPHVIZ_VERSION_GOOD TRUE)
if(ValadocGraphviz_FIND_VERSION)
  if("${LIBGRAPHVIZ_VERSION}" VERSION_LESS "${ValadocGraphviz_FIND_VERSION}" OR
      (ValadocGraphviz_FIND_VERSION_EXACT AND NOT
      "${LIBGRAPHVIZ_VERSION}" VERSION_EQUAL "${ValadocGraphviz_FIND_VERSION}"))
    set(LIBGRAPHVIZ_VERSION_GOOD FALSE)
  endif()
endif()

# handle arguments
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ValadocGraphviz DEFAULT_MSG
  LIBGRAPHVIZ_INCLUDE_DIR
  LIBGRAPHVIZ_GVC_LIBRARY
  LIBGRAPHVIZ_GRAPH_LIBRARY
  LIBGRAPHVIZ_CDT_LIBRARY
  LIBGRAPHVIZ_VERSION_GOOD
  )

set(LIBGRAPHVIZ_LIBRARIES
  "${LIBGRAPHVIZ_GVC_LIBRARY}"
  "${LIBGRAPHVIZ_GRAPH_LIBRARY}"
  "${LIBGRAPHVIZ_CDT_LIBRARY}"
  )
