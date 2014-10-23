namespace Arrive {
    public class App : Granite.Application {
        public Widgets.MainWindow main_window;
        public Model.IDownloadList download_list;
        public Model.FinishedList finished_list;
        public Model.Settings settings;
        private static string? uri;
        public static bool quiet;
        private static App _instance;
        public static App instance {
            get {
                if (_instance == null)
                    _instance = new App ();
                return _instance;
            }
        }
        construct {
            debug ("construct");
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
            application_id = "org.pantheon.arrive";

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
        }
        protected override void activate () {
            if (DEBUG)
                Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
            else
                Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.INFO;

            debug ("activate " + uri);

            if (Model.aria2 == null) {
                settings = new Model.Settings ();
                download_list = new Model.DownloadList ();
                finished_list = new Model.FinishedList ();
                Model.aria2 = new Model.Aria2 (download_list, finished_list);
                //bad bad code
                (download_list as Model.DownloadList).start ();
            }

            if (main_window == null)
                main_window = new Widgets.MainWindow (download_list, finished_list);

            main_window.set_application (this);

            if (quiet)
                message ("download " + uri);
            else if (uri != null)
                main_window.create_add_dialog (uri);
            else
                main_window.present ();

            var launcher_entry = new Arrive.Model.LauncherEntry ();
        }
        public static const OptionEntry[] entries = {
                { "add", 'a', 0, OptionArg.STRING, ref uri, "Show Add Download dialog.", null },
                { "quiet", 'q', 0, OptionArg.NONE, ref quiet, "Start downloading the url.", null },
                { null }
            };
        public static int main (string[] args) {
            Gtk.init (ref args);
            debug ("main");

            var context = new OptionContext ("");
            context.add_main_entries (entries, "arrive");
            context.add_group (Gtk.get_option_group (true));

            try {
                context.parse (ref args);
            }
            catch(Error e) {
                print (e.message);
            }

            instance.run (args);

            return 0;
        }
    }
}
