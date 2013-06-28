namespace Arrive.Model {
    public class AriaTorrent : Object, IDownloadItem {
        public AriaTorrent (string[] uris){
        }
        public string gid {get; private set;}
        public string item_type {get; protected set;}
        public string filename {get; private set;}
        public string dir {get; private set;}
        public string status {get; private set;}
        public uint64 total_length {get; private set;}
        public uint64 completed_length {get; private set;}
        public uint download_speed {get; private set;}
        public uint upload_speed {get; private set;}
        public void start (){
        }
        public void pause (){
        }
        public void unpause (){
        }
        public void remove (){
        }
        public void cancel (){
        }
    }
}
