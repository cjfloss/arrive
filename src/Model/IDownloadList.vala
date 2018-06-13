namespace Arrive.Model {
public static Model.IDownloadList download_list;
public interface IDownloadList : Object {
    public abstract List<IDownloadItem> files{get;}
    public abstract IDownloadItem ? get_by_gid (string gid);
    public abstract void add_file (IDownloadItem download_item);
    public abstract void remove_file (IDownloadItem download_item);

    public signal void file_added (IDownloadItem download_item);
    public signal void file_removed (IDownloadItem download_item);
    public signal void item_refreshed ();
}
}
