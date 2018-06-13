project ('com.github.cjfloss.arrive', 'vala', 'c')

conf_data = configuration_data()
conf_data.set('PROJECT_NAME', meson.project_name())
conf_data.set('EXEC_NAME', meson.project_name())
conf_data.set('DATADIR', get_option('datadir'))
conf_data.set('PKGDATADIR', get_option('datadir') + '/' + meson.project_name())
conf_data.set('GETTEXT_PACKAGE', meson.project_name())
conf_data.set('RELEASE_NAME', 'Download Manager')
conf_data.set('VERSION', '0.4.0')
conf_data.set('VERSION_INFO', 'Release')
conf_data.set('PREFIX', get_option('prefix'))
#config_header = configure_file(
#    input: 'config.vala.in',
#    output: 'config.vala',
#    configuration: conf_data
#)

# Include the translations module
i18n = import('i18n')

# Include the gnome module
gnome = import('gnome')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

subdir('src')
subdir('data')
subdir('po')

meson.add_install_script('data/post_install.py')
