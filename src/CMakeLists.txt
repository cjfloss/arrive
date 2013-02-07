# Check http://webdev.elementaryos.org/docs/developer-guide/cmake for documentation

# Configure file
find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.15.1" MINIMUM)
include (ValaPrecompile)
configure_file (${CMAKE_SOURCE_DIR}/src/config.vala.cmake ${CMAKE_SOURCE_DIR}/src/config.vala)
message( ${CMAKE_SOURCE_DIR}/src/config.vala)
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
#configure_file (${CMAKE_SOURCE_DIR}/src/appcenter.pc.cmake ${CMAKE_BINARY_DIR}/src/appcenter.pc)
#install (FILES ${CMAKE_BINARY_DIR}/src/appcenter.pc DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig/)
# appcenter

set (ARRIVE_DEPS "gtk+-3.0;granite;libsoup-2.4;libxml-2.0")
find_package (PkgConfig)
pkg_check_modules (GTK+ REQUIRED "gtk+-3.0 >= 3.4")
pkg_check_modules (LIBGRANITE REQUIRED "granite")
pkg_check_modules (DEPS REQUIRED ${ARRIVE_DEPS} gthread-2.0)
set(NORMAL_CFLAGS ${DEPS_CFLAGS} ${LIBSOURCE_CFLAGS} ${GCONF_CFLAGS})
set(NORMAL_LINK_DIRS ${DEPS_LIBRARY_DIRS} ${LIBSOURCE_LIBRARY_DIRS} ${GCONF_LIBRARY_DIRS})
set(NORMAL_LIBRARIES ${DEPS_LIBRARIES} ${LIBSOURCE_LIBRARIES} ${GCONF_LIBRARIES})
add_definitions (${DEPS_CFLAGS} ${LIBSOURCE_CFLAGS} ${GCONF_CFLAGS})
link_libraries (${DEPS_LIBRARIES} ${LIBSOURCE_LIBRARIES} ${GCONF_LIBRARIES} ${GTHREAD_LIBRARIES})
link_directories (${DEPS_LIBRARY_DIRS} ${LIBSOURCE_LIBRARY_DIRS} ${GCONF_LIBRARY_DIRS})
vala_precompile(VALA_C
    Arrive.vala
    config.vala
    Widgets/MainWindow.vala
    Widgets/CellRenderer.vala
    Widgets/DownloadingList.vala
    Widgets/FinishedList.vala
    Model/Aria2Model.vala
PACKAGES
    ${ARRIVE_DEPS}
OPTIONS
    --vapidir=${CMAKE_SOURCE_DIR}/vapi
    --thread
)

add_executable (arrive ${VALA_C})
#add_dependencies(appcenter appcentercore)
#include_directories(${CMAKE_BINARY_DIR}/appcentercore)
#include_directories(${CMAKE_BINARY_DIR}/lib)
#target_link_libraries (appcenter)

install(TARGETS arrive RUNTIME DESTINATION bin)
