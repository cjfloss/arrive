namespace Arrive.Model {
    public class DownloadList : Object, Model.IDownloadList {
        private List<Model.IDownloadItem> _files;
        private string _save_file = Environment.get_user_data_dir () + "/"
                                    + "aria" + "/aria.xml";
        public List<Model.IDownloadItem> files {
            get {return _files;}
        }
        public DownloadList (string save_file){
            _save_file = save_file;
            _files = new List<Model.IDownloadItem>();
        }
        public void destroy (){
            debug ("download list destructed");
            save_list (_save_file);
        }
        public void start (){
            load_list (_save_file);
        }
        public Model.IDownloadItem nth_data (int nth){
            return _files.nth_data (0);
        }
        public Model.IDownloadItem? get_by_gid (string gid){
            foreach (Model.IDownloadItem d_item in _files){
                if (gid == d_item.gid)
                    return d_item;
            }
            return null;
        }
        public List<Model.IDownloadItem> get_by_status (string status){
            var finished_items = new List<Model.IDownloadItem> ();
            foreach (Model.IDownloadItem d_item in _files){
                if (d_item.status == status){
                    finished_items.append (d_item);
                }
            }
            return finished_items;
        }
        public Model.IDownloadItem? get_by_filename (string filename){
            return null;
        }
        public Model.IDownloadItem? get_by_path (string path){
            return null;
        }
        public int get_length (){
            if (_files == null)return 0;
            return (int) _files.length ();
        }
        public void add_file (Model.IDownloadItem download_item){
            debug ("add_file:"+download_item.filename);
            _files.append (download_item);
            file_added (download_item);
            save_list (_save_file);
        }
        public void remove_file (Model.IDownloadItem download_item){
            download_item.remove ();
            remove (download_item);
        }
        public void remove (Model.IDownloadItem download_item){
            _files.remove (download_item);
            file_removed (download_item);
            save_list (_save_file);
            debug ("file removed, length "+get_length ().to_string ());
        }
        private void save_list (string filename){
            ValueArray va = new ValueArray (0);
            foreach (Model.IDownloadItem d_item in _files)
                if (d_item is Model.AriaHttp){
                    var val = Value (typeof(HashTable));
                    val = (d_item as Model.AriaHttp).get_ht ();
                    va.append (val);
                }else{
                    var val = Value (typeof(HashTable));
                    val = (d_item as AriaMagnet).get_ht ();
                    debug ("uris "+(d_item as AriaMagnet).uris);
                    va.append (val);
                }

            var data = Soup.XMLRPC.build_method_response (va);

            Utils.save_string (_save_file, data);
            debug ("list saved as :"+filename);
        }
        private void load_list (string filename){
            debug ("load list from :"+filename);
            var data = Utils.load_string (_save_file);
            try {
                Value v;
                if(Soup.XMLRPC.parse_method_response (data, -1, out v)
                   && v.holds (typeof(ValueArray))) { //get value from xml string
                    unowned ValueArray va;
                    va =(ValueArray) v;
                    foreach(Value viter in va) {
                        if(viter.holds (typeof(HashTable))) {
                            HashTable<string, Value ?> ht = (HashTable<string, Value ?>) viter;
                            switch (ht.get ("item_type").get_string ()){
                                case "AriaHttp" :
                                    var aria_http = new Model.AriaHttp.with_ht (ht);
                                    add_file (aria_http);
                                break;
                                case "AriaMagnet" :
                                    var aria_magnet = new Model.AriaMagnet.with_ht (ht);
                                    add_file (aria_magnet);
                                break;
                            }
                        }
                    }
                }
            } catch (Error e){
                warning ("cant loadlist : %s", e.message);
            }
        }
    }
}
