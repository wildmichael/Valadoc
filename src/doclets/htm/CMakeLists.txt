
vala_add_library(htmldoclet MODULE doclet.vala
  PACKAGES libvaladoc)

target_link_libraries(htmldoclet libvaladoc)

set_target_properties(htmldoclet PROPERTIES
  OUTPUT_NAME doclet
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/valadoc/plugins/html"
  )

install(TARGETS htmldoclet
  LIBRARY DESTINATION "${VALADOC_LIB_DIR}/valadoc/plugins/html" COMPONENT shlibs
  )

