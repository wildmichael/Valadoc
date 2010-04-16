
vala_add_library(devhelpdoclet MODULE doclet.vala
  PACKAGES libvaladoc)

target_link_libraries(devhelpdoclet libvaladoc)

set_target_properties(devhelpdoclet PROPERTIES
  OUTPUT_NAME doclet
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/valadoc/plugins/devhelp"
  )

install(TARGETS devhelpdoclet
  LIBRARY DESTINATION "${VALADOC_LIB_DIR}/valadoc/plugins/devhelp" COMPONENT shlibs
  )

