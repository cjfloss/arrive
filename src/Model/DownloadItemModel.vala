public interface Arrive.Model.IDownloadItem :
Glib.Object {
    public enum download_type {
        URI=0,
        TORRENT,
        METALINK
    }
    public enum status {
        ACTIVE=0,
        WAITING,
        PAUSED,
        ERROR,
        COMPLETE,
        REMOVED
    }
    string gid;
    string filename;
    string dir;
    string[] uris;
    uint64 total_length;
    uint64 completed_length;
    uint64 upload_length;
    int download_speed;
    int upload_speed;
    int info_hash;
    int num_seeder;
    int piece_length;
    int num_pieces;
    int connections;
    string error_code;
    string[] followed_by;
    string belongs_to;
    string dir;
    string[] files;
    int bt-max-peers;
    int bt-request-peer-speed-limit;
    int max-download-limit;
    int max-upload-limit;

}
