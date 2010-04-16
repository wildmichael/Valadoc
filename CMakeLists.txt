project(Valadoc C)

# version information
#####################
set(VALADOC_VERSION 0.2)
set(VALADOC_SOVERSION 2.0.0)
set(VALADOC_MINIMUM_VALA_VERSION 0.7.7)
set(VALADOC_MINIMUM_GEE_VERSION 0.5)
set(VALADOC_MINIMUM_GRAPHVIZ_VERSION 2.16)
set(VALADOC_MINIMUM_GDKPIXBUF_VERSION 2.0)
set(VALADOC_MINIMUM_CMAKE_VERSION 2.8)

cmake_minimum_required(VERSION ${VALADOC_MINIMUM_CMAKE_VERSION})

# find required tools
#####################
find_package(Vala ${VALADOC_MINIMUM_VALA_VERSION} REQUIRED)
include("${VALA_USE_FILE}")
find_package(Gee ${VALADOC_MINIMUM_GEE_VERSION} REQUIRED)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" "${VALA_CMAKE_DIR}")
find_package(ValadocGraphviz ${VALADOC_MINIMUM_GRAPHVIZ_VERSION} REQUIRED)
find_package(ValadocGdkPixbuf ${VALADOC_MINIMUM_GDKPIXBUF_VERSION} REQUIRED)
find_package(ValaGModule2 REQUIRED)

# options and installation paths
################################
set(VALADOC_BIN_DIR bin CACHE STRING "Installation directory for executables")
set(VALADOC_LIB_DIR lib CACHE STRING "Installation directory for libraries")
set(VALADOC_INC_DIR include CACHE STRING
  "Installation directory for development headers")
set(VALADOC_DATA_DIR share CACHE STRING
  "Installation directory for data files")
# make paths absolute
foreach(d BIN LIB INC DATA)
  if(NOT IS_ABSOLUTE "${VALADOC_${d}_DIR}")
    set(VALADOC_${d}_DIR "${CMAKE_INSTALL_PREFIX}/${VALADOC_${d}_DIR}")
  endif()
endforeach()

# output directories
####################
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

# include directories
#####################
include_directories(
  "${CMAKE_BINARY_DIR}"
  "${CMAKE_BINARY_DIR}/src/libvaladoc"
  ${VALA_INCLUDE_DIRS}
  "${VALA_DEV_INCLUDE_DIR}"
  "${GEE_INCLUDE_DIR}"
  "${LIBGRAPHVIZ_INCLUDE_DIR}"
  "${GDKPIXBUF_INCLUDE_DIR}"
  )
list(APPEND VALA_VAPI_DIRS "${CMAKE_BINARY_DIR}/vapi")

# set up definitions
####################
add_definitions(-DPACKAGE_ICONDIR="${VALADOC_DATA_DIR}/valadoc/icons/")

if(APPLE)
  set(CMAKE_INSTALL_NAME_DIR "${VALADOC_LIB_DIR}")
elseif(UNIX)
  set(CMAKE_INSTALL_RPATH "${VALADOC_LIB_DIR}")
endif()

# build valdoc
##############
configure_file(config.h.in "${CMAKE_BINARY_DIR}/config.h" @ONLY)
configure_file(src/vapi/config.vapi
  "${CMAKE_BINARY_DIR}/vapi/config.vapi" @ONLY)
add_subdirectory(src)
add_subdirectory(icons)

# export targets to build and install tree
##########################################
export(TARGETS libvaladoc valadoc
  NAMESPACE Valadoc:
  FILE "${CMAKE_BINARY_DIR}/ValadocExports.cmake")
if(${CMAKE_VERSION} VERSION_GREATER 2.6.4)
  export(PACKAGE Valadoc)
endif()
install(EXPORT ValadocExports
  DESTINATION "${VALADOC_DATA_DIR}/valadoc/cmake"
  NAMESPACE Valadoc:
  COMPONENT dev)

# configure and install CMake files
###################################
configure_file(cmake/ValadocConfigVersion.cmake.in
  "${CMAKE_BINARY_DIR}/ValadocConfigVersion.cmake" @ONLY)
# set up for build tree
set(CONFIG_CMAKE_DIR "${CMAKE_BINARY_DIR}")
set(CONFIG_VAPI_DIR "${CMAKE_BINARY_DIR}/vapi")
configure_file(cmake/ValadocConfig.cmake.in
  "${CMAKE_BINARY_DIR}/ValadocConfig.cmake" @ONLY)
# set up for install tree
set(CONFIG_CMAKE_DIR "${VALADOC_DATA_DIR}/valadoc/cmake")
set(CONFIG_VAPI_DIR "${VALADOC_DATA_DIR}/vala/vapi")
configure_file(cmake/ValadocConfig.cmake.in
  "${CMAKE_BINARY_DIR}/install_files/ValadocConfig.cmake" @ONLY)
# install the cmake files
install(FILES
  "${CMAKE_BINARY_DIR}/ValadocConfigVersion.cmake"
  "${CMAKE_BINARY_DIR}/install_files/ValadocConfig.cmake"
  DESTINATION "${CONFIG_CMAKE_DIR}" COMPONENT dev)
