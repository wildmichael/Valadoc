
vala_add_library(xmldoclet MODULE
  xmlmarkupwriter.vala
  xmlrenderer.vala
  doclet.vala
  PACKAGES libvaladoc)

target_link_libraries(xmldoclet libvaladoc)

set_target_properties(xmldoclet PROPERTIES
  OUTPUT_NAME doclet
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/valadoc/plugins/xml"
  )

install(TARGETS xmldoclet
  LIBRARY DESTINATION "${VALADOC_LIB_DIR}/valadoc/plugins/xml" COMPONENT shlibs
  )

