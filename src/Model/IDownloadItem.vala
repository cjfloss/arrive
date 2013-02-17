public interface Arrive.Model.IDownloadItem :
        Object {
    public enum DownloadType {
        URI=0,
        TORRENT,
        METALINK
    }
    public enum Status {
        ACTIVE=0,
        WAITING,
        PAUSED,
        ERROR,
        COMPLETE,
        REMOVED
    }
    public abstract DownloadType tipe{get;set;}
    public abstract Status status{get;set;}
    public abstract string gid{get;set;}
    public abstract string filename{get;set;}
    public abstract string dir{get;set;}
    //public abstract ValueArray uris{get;set;}
    public abstract uint64 total_length{get;set;}
    public abstract uint64 completed_length{get;set;}
//~     public abstract uint64 upload_length;
    public abstract uint download_speed{get;set;}
    public abstract uint upload_speed{get;set;}
//~     int info_hash;
//~     int num_seeder;
//~     int piece_length;
//~     int num_pieces;
//~     int connections;
//~     string error_code;
//~     string[] followed_by;
//~     string belongs_to;
//~     string[] files;
//~     int bt-max-peers;
//~     int bt-request-peer-speed-limit;
//~     int max-download-limit;
//~     int max-upload-limit;
}
