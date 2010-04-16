vala_add_library(libvaladoc SHARED
  doclet.vala
  errorreporter.vala
  filehelper.vala
  moduleloader.vala
  settings.vala
  markupwriter.vala
  devhelp-markupwriter.vala
  documentation/commentscanner.vala
  documentation/documentation.vala
  documentation/documentationparser.vala
  documentation/wiki.vala
  documentation/wikiscanner.vala
  importer/documentationimporter.vala
  importer/valadocdocumentationimporter.vala
  importer/valamarkupreader.vala
  api/array.vala
  api/class.vala
  api/constant.vala
  api/delegate.vala
  api/enum.vala
  api/enumvalue.vala
  api/errorcode.vala
  api/errordomain.vala
  api/field.vala
  api/formalparameter.vala
  api/interface.vala
  api/item.vala
  api/member.vala
  api/method.vala
  api/namespace.vala
  api/node.vala
  api/nodebuilder.vala
  api/package.vala
  api/pointer.vala
  api/property.vala
  api/propertyaccessor.vala
  api/signal.vala
  api/signaturebuilder.vala
  api/struct.vala
  api/symbol.vala
  api/tree.vala
  api/typeparameter.vala
  api/typereference.vala
  api/typesymbol.vala
  api/visitable.vala
  api/visitor.vala
  content/block.vala
  content/blockcontent.vala
  content/comment.vala
  content/contentfactory.vala
  content/contentelement.vala
  content/contentrenderer.vala
  content/contentvisitor.vala
  content/embedded.vala
  content/headline.vala
  content/inline.vala
  content/inlinetaglet.vala
  content/inlinecontent.vala
  content/link.vala
  content/list.vala
  content/listitem.vala
  content/page.vala
  content/paragraph.vala
  content/resourcelocator.vala
  content/run.vala
  content/sourcecode.vala
  content/styleattributes.vala
  content/symbollink.vala
  content/table.vala
  content/tablecell.vala
  content/tablerow.vala
  content/taglet.vala
  content/text.vala
  charts/chart.vala
  charts/chartfactory.vala
  charts/hierarchychart.vala
  charts/simplechartfactory.vala
  parser/manyrule.vala
  parser/oneofrule.vala
  parser/optionalrule.vala
  parser/parser.vala
  parser/parsercallback.vala
  parser/rule.vala
  parser/scanner.vala
  parser/sequencerule.vala
  parser/sourcelocation.vala
  parser/stubrule.vala
  parser/token.vala
  parser/tokentype.vala
  taglets/tagletdeprecated.vala
  taglets/tagletinheritdoc.vala
  taglets/tagletinit.vala
  taglets/tagletlink.vala
  taglets/tagletparam.vala
  taglets/tagletreturn.vala
  taglets/tagletsee.vala
  taglets/tagletsince.vala
  taglets/tagletthrows.vala
  html/basicdoclet.vala
  html/htmlchartfactory.vala
  html/linkhelper.vala
  html/cssclassresolver.vala
  html/htmlmarkupwriter.vala
  html/htmlrenderer.vala
  LIBRARY valadoc-1.0
  GENERATE_HEADER valadoc-1.0.h
  GENERATE_VAPI "${CMAKE_BINARY_DIR}/vapi/valadoc-1.0.vapi"
  PACKAGES Gee:gee Vala:vala libgvc config gmodule-2.0
  )

set(LINK_LIBS
  ${LIBGRAPHVIZ_LIBRARIES}
  ${GEE_LIBRARIES}
  ${VALA_DEV_LIBRARIES}
  ${VALA_LIBRARIES}
  ${GMODULE2_LIBRARIES}
  )
list(REMOVE_DUPLICATES LINK_LIBS)

target_link_libraries(libvaladoc ${LINK_LIBS})

set_target_properties(libvaladoc PROPERTIES
  OUTPUT_NAME valadoc
  PUBLIC_HEADER "${CMAKE_CURRENT_BINARY_DIR}/valadoc-1.0.h"
  )

install(TARGETS libvaladoc EXPORT ValadocExports
  ARCHIVE DESTINATION "${VALADOC_LIB_DIR}" COMPONENT dev
  RUNTIME DESTINATION "${VALADOC_BIN_DIR}" COMPONENT shlibs
  LIBRARY DESTINATION "${VALADOC_LIB_DIR}" COMPONENT shlibs
  PUBLIC_HEADER DESTINATION "${VALADOC_INC_DIR}" COMPONENT dev
  )

install(FILES "${CMAKE_BINARY_DIR}/vapi/valadoc-1.0.vapi" valadoc-1.0.deps
  DESTINATION "${VALADOC_DATA_DIR}/vala/vapi" COMPONENT dev)

# configure and install pkg-config file
#######################################
set(VERSION "${VALADOC_VERSION}")
set(prefix "${CMAKE_INSTALL_PREFIX}")
set(exec_prefix)
set(libdir "${VALADOC_LIB_DIR}")
set(includedir "${VALADOC_INC_DIR}")
set(datarootdir "${VALADOC_DATA_DIR}")
set(datadir "\${datarootdir}")
set(vapidir "\${datarootdir}/vala/vapi")
configure_file(valadoc-1.0.pc.in "${CMAKE_BINARY_DIR}/install_files/valadoc-1.0.pc" @ONLY)
install(FILES "${CMAKE_BINARY_DIR}/install_files/valadoc-1.0.pc"
  DESTINATION "${VALADOC_LIB_DIR}/pkgconfig" COMPONENT dev)

