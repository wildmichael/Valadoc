add_definitions(
  -DPACKAGE_DATADIR="${VALADOC_LIB_DIR}/valadoc/plugins"
  )

vala_add_executable(valadoc valadoc.vala
  PACKAGES libvaladoc)

target_link_libraries(valadoc libvaladoc)

install(TARGETS valadoc EXPORT ValadocExports
  RUNTIME DESTINATION "${VALADOC_BIN_DIR}" COMPONENT bin
  )
