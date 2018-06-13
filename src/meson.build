# Create a new executable,
#  - list the files we want to compile,
#  - list the dependencies we need,
#  - and install
executable(
    meson.project_name(),
    'Arrive.vala',
    'Utils.vala',

    'Widgets/AddFileDialog.vala',
    #'Widgets/AddFilePopOver.vala',
    'Widgets/CellRenderer.vala',
    'Widgets/DownloadingList.vala',
    'Widgets/DownloadListWelcome.vala',
    'Widgets/FinishedList.vala',
    'Widgets/FinishedListWelcome.vala',
    'Widgets/MainWindow.vala',
    'Widgets/WelcomeWidget.vala',

    'Model/Aria2.vala',
    'Model/AriaHttp.vala',
    'Model/AriaMagnet.vala',
    'Model/AriaTorrent.vala',
    'Model/DownloadItem.vala',
    'Model/DownloadList.vala',
    'Model/FinishedItem.vala',
    'Model/FinishedList.vala',
    'Model/IDownloadItem.vala',
    'Model/IDownloadList.vala',
    'Model/LauncherEntry.vala',
    'Model/Settings.vala',

    dependencies: [
        dependency('gtk+-3.0', version :'>=3.10'),
        dependency('libsoup-2.4',),
        dependency('gee-0.8'),
        dependency('gio-2.0'),
        dependency('granite', version :'>=0.3.0'),
        dependency('libnotify'),
    ],
    install: true
)