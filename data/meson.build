icon_sizes = ['16', '24', '32', '48', '64', '128']

meson.add_install_script ('post_install.py')

foreach i : icon_sizes
    install_data(
        join_paths('icons', i , meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
    install_data(
        join_paths('icons', i , meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps')
    )
endforeach

install_data(
    join_paths('icons', '128' , meson.project_name() + '.svg'),
    install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'scalable', 'apps')
)

install_data (
    meson.project_name () + '.gschema.xml',
    install_dir : join_paths (get_option ('datadir'), 'glib-2.0', 'schemas')
)


i18n.merge_file(
    input: meson.project_name() + '.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

i18n.merge_file(
    input: meson.project_name() + '.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

dvf = find_program('desktop-file-validate', required: false)
if dvf.found()
test (
    'Validate desktop file',
    dvf,
    args : join_paths (meson.current_build_dir (), meson.project_name () + '.desktop')
)
endif

asc = find_program('appstreamcli', required : false)
if asc.found()
test (
   'Validate appdata file',
    asc,
    args : ['validate', join_paths (meson.current_build_dir (), meson.project_name () + '.appdata.xml')]
)
endif

vala_lint = find_program ('io.elementary.vala-lint', required: false)
if vala_lint.found()
  test (
    'Vala lint',
    vala_lint,
    args: ['-d', join_paths (meson.source_root (), 'src')]
  )
endif
