public class Arrive.Model.LauncherEntry:Object{
    private static int REFRESH_TIME=1000;
    private Unity.LauncherEntry le;
    public LauncherEntry(){
        le = Unity.LauncherEntry.get_for_desktop_id("arrive.desktop");
//~         Arrive.App.aria2.download_list._list.notify("length").connect(()=>{
//~             set_progress();
//~         });
        var refresh_timer = new TimeoutSource(REFRESH_TIME);
        refresh_timer.set_callback(()=>{
            set_progress();
            return true;
        });
        refresh_timer.attach(null);
    }
    private void set_progress(){
        uint64 completed_length=0;
        uint64 total_length=0;

        foreach(Arrive.Model.DownloadItem d_item in Arrive.App.aria2.download_list._list){
            completed_length+=d_item.completed_length;
            total_length+=total_length;
        }
        double completed_percentage=completed_length/total_length;

        if(completed_length != 1.0){
            le.progress = completed_length;
            le.progress_visible=true;
        }else{
            le.progress = 1.0;
            le.progress_visible=false;
        }
    }
}
