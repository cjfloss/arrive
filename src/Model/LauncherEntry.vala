namespace Arrive.Model {
//FIXME:for now its not working as we try to be as Gnome as possible,
//get Unity library from somewhere else
public class LauncherEntry : Object {
    private static int REFRESH_TIME=1000;
    //private Unity.LauncherEntry le;
    private DownloadList _download_list;
    public LauncherEntry (DownloadList download_list) {
        _download_list = download_list;
        //le = Unity.LauncherEntry.get_for_desktop_id("Arrive.desktop");

        var refresh_timer = new TimeoutSource (REFRESH_TIME);
        refresh_timer.set_callback (()=> {
            set_progress (calculate_progress ());
            return true;
        });
        refresh_timer.attach (null);
    }
    private void set_progress(double progress) {
        //    if (progress < 1.0 && progress > 0.0) {
        //        le.progress = progress;
        //        le.progress_visible = true;
        //    }else{
        //       le.progress_visible = false;
        //    }
    }
    private double calculate_progress () {
        uint64 completed_length = 0;
        uint64 total_length = 0;

        foreach(IDownloadItem d_item in _download_list.files) {
            if (d_item.status == "active") {
                completed_length += d_item.completed_length;
                total_length += d_item.total_length;
            }
        }
        double completed_percentage = (double) completed_length / total_length;
        return completed_percentage;
    }
}
}
