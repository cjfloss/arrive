# Check http://webdev.elementaryos.org/docs/developer-guide/cmake for documentation

cmake_minimum_required (VERSION 2.6)
cmake_policy (VERSION 2.6)
project (arrive)
enable_testing ()
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/arrive")
set (GETTEXT_PACKAGE "arrive")
set (RELEASE_NAME "Download Manager")
set (VERSION "0.1")
set (VERSION_INFO "Release")
set (CMAKE_C_FLAGS "-ggdb")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$")
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

add_subdirectory (src)
add_subdirectory(po)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/Arrive.desktop DESTINATION share/applications)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/arrive.svg DESTINATION share/icons/hicolor/48x48/apps)

include(GSettings)
add_schema("data/org.pantheon.Arrive.gschema.xml")
