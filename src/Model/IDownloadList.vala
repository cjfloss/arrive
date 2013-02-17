public interface Arrive.Model.IDownloadList :
Object {
    //public Gee.List <IDownloadItem> list;
    public abstract IDownloadItem? get_file(string gid);
    public signal void add_file(IDownloadItem download_item);
   // public signal void remove_file (IDownloadItem download_item);
//~     public signal file_added(IDownloadItem file);
//~     public signal file_removed(IDownloadItem file);
}
