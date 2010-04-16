
vala_add_library(gtkdocdoclet MODULE
  commentconverter.vala
  doclet.vala
  gcomment.vala
  generator.vala
  utils.vala
  PACKAGES libvaladoc)

target_link_libraries(gtkdocdoclet libvaladoc)

set_target_properties(gtkdocdoclet PROPERTIES
  OUTPUT_NAME doclet
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/valadoc/plugins/gtkdoc"
  )

install(TARGETS gtkdocdoclet
  LIBRARY DESTINATION "${VALADOC_LIB_DIR}/valadoc/plugins/gtkdoc" COMPONENT shlibs
  )

