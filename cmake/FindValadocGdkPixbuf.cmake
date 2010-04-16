#- Find the gdk_pixbuf library
# Sets the following variables:
#  GDKPIXBUF_FOUND
#  GDKPIXBUF_INCLUDE_DIR
#  GDKPIXBUF_LIBRARIES
#  GDKPIXBUF_VERSION
#

# find include path
find_path(GDKPIXBUF_INCLUDE_DIR gdk-pixbuf/gdk-pixbuf-features.h
  PATH_SUFFIXES gtk-2.0)

# fnd the library
find_library(GDKPIXBUF_LIBRARY gdk_pixbuf-2.0)

# parse version
if(GDKPIXBUF_INCLUDE_DIR)
  file(READ "${GDKPIXBUF_INCLUDE_DIR}/gdk-pixbuf/gdk-pixbuf-features.h" _gpb_version_h)
  string(REGEX REPLACE ".*#define[ \t]+GDK_PIXBUF_VERSION[ \t]+\"(.+)\".*" "\\1"
    GDKPIXBUF_VERSION "${_gpb_version_h}")
  if(NOT GDKPIXBUF_VERSION)
    message(FATAL_ERROR "Failed to parse version from"
      "${GDKPIXBUF_INCLUDE_DIR}/gdk-pixbuf/gdk-pixbuf-features.h")
  endif()
endif()

# check package version
set(GDKPIXBUF_VERSION_GOOD TRUE)
if(ValadocGdkPixbuf_FIND_VERSION)
  if("${GDKPIXBUF_VERSION}" VERSION_LESS "${ValadocGdkPixbuf_FIND_VERSION}" OR
      (ValadocGdkPixbuf_FIND_VERSION_EXACT AND NOT
      "${GDKPIXBUF_VERSION}" VERSION_EQUAL "${ValadocGdkPixbuf_FIND_VERSION}"))
      set(GDKPIXBUF_VERSION_GOOD FALSE)
  endif()
endif()

# handle arguments
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ValadocGdkPixbuf DEFAULT_MSG
  GDKPIXBUF_INCLUDE_DIR GDKPIXBUF_LIBRARY GDKPIXBUF_VERSION_GOOD)

set(GDKPIXBUF_LIBRARIES "${GDKPIXBUF_LIBRARY}")
