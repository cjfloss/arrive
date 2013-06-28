namespace Arrive {
    public class App : Granite.Application {
        public static Widgets.MainWindow main_window;
        //public static Arrive.Model.Aria2 aria2;
        public Model.IDownloadList download_list;
        private static App _instance;
        public static App instance {
            get{
                if (_instance == null)
                    _instance = new App ();
                return _instance;
            }
        }
        construct {

            build_data_dir = Build.DATADIR;
            build_pkg_data_dir = Build.PKG_DATADIR;
            build_release_name = Build.RELEASE_NAME;
            build_version = Build.VERSION;
            build_version_info = Build.VERSION_INFO;

            program_name = "Arrive";
            exec_name = "arrive";

            app_copyright = "2013";
            app_years = "2013";
            app_icon = "arrive";
            app_launcher = "Arrive.desktop";
            application_id = "org.vikoadi.arrive";

            main_url = "https://launchpad.net/arrive";
            bug_url = "https://bugs.launchpad.net/arrive";
            help_url = "https://answers.launchpad.net/arrive";
            translate_url = "https://translations.launchpad.net/arrive";

            about_authors = {"Viko Adi Rahmawan <vikoadi@gmail.com>", null };
            about_comments = _("Simple and practical download manager");
            about_documenters = {};
            about_artists = {};
            about_translators = "Launchpad Translators";

            about_license_type = Gtk.License.GPL_3_0;
            _instance = this;
        }
        protected override void activate () {
            if (DEBUG)
                Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
            else
                Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.INFO;
            
            download_list = new Model.DownloadList ();
            
            if (Model.aria2 == null){
                Model.aria2 = new Model.Aria2 (download_list);
                (download_list as Model.DownloadList).start ();
            }
            
            if (main_window == null) main_window = new Widgets.MainWindow ();
            main_window.set_application (this);
            main_window.present ();
            
            var launcher_entry = new Arrive.Model.LauncherEntry();
        }
    }
}
public static int main (string[] args) {
    Gtk.init (ref args);
    Notify.init(Arrive.App.instance.application_id);
    Arrive.App.instance.run (args);
    return 0;
}
