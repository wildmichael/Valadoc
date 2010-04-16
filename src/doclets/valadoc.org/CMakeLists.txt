
vala_add_library(valadocorgdoclet MODULE htmlrenderer.vala doclet.vala
  PACKAGES libvaladoc)

target_link_libraries(valadocorgdoclet libvaladoc)

set_target_properties(valadocorgdoclet PROPERTIES
  OUTPUT_NAME doclet
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/valadoc/plugins/valadoc.org"
  )

install(TARGETS valadocorgdoclet
  LIBRARY DESTINATION "${VALADOC_LIB_DIR}/valadoc/plugins/valadoc.org" COMPONENT shlibs
  )

