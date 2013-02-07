public class Arrive.App : Granite.Application {
    public Arrive.Widgets.MainWindow main_window = null;
    private static App _instance;
    public static App instance {
        get{
            if (_instance == null)
                _instance = new App();
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
        app_launcher = "arrive.desktop";
        application_id = "org.vikoadi.arrive";

//~         main_url = "https://launchpad.net/bouquin";
//~         bug_url = "https://bugs.launchpad.net/bouquin";
//~         help_url = "https://answers.launchpad.net/bouquin";
//~         translate_url = "https://translations.launchpad.net/bouquin";

        about_authors = {"Viko Adi Rahmawan <vikoadi@gmail.com>", null };
        about_comments = _("Download Manager that support http and ftp");
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

        var main_window = new Arrive.Widgets.MainWindow ();
        main_window.set_application (this);

    }
}

public static int main (string[] args) {
    Gtk.init(ref args);
    return Arrive.App.instance.run (args);
    //var aria2 = new Arrive.Aria2Model();
    //stdout.printf(aria2.num_active.to_string());
    return 0;
}
