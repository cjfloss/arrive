namespace Arrive.Model {
public interface IDownloadItem :
    Object {
    public enum Status {
        ACTIVE=0,
        WAITING,
        PAUSED,
        ERROR,
        COMPLETE,
        REMOVED
    }
    public abstract string gid {get; set;}
    public abstract string status {get; set;}
    public abstract string item_type {get; set;}//used to identify IDownlaodItem type when loading from file
    public abstract string filename {get; set;}
    public abstract string dir {get; set;}
    public abstract uint64 total_length {get; set;}
    public abstract uint64 completed_length {get; set;}
    public abstract uint download_speed {get; set;}
    public abstract uint upload_speed {get; set;}
    //public abstract Gtk.CellRenderer cell_renderer;
    public abstract void start ();
    public abstract void pause ();
    public abstract void unpause ();
    public abstract void remove ();
    public abstract void cancel ();

    public signal void refreshed ();
}
}
