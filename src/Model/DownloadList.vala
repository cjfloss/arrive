namespace Arrive.Model {
    public class DownloadList : Object, Model.IDownloadList {
        private List<Model.IDownloadItem> _files;
        private string save_file = Environment.get_user_data_dir () + "/" 
                                    + App.instance.program_name + "/aria.xml";
        public List<Model.IDownloadItem> files {
            get {return _files;}
        }
        public DownloadList (){
            _files = new List<Model.IDownloadItem>();
        }
        public void destroy (){
            message ("download list destructed");
            save_list (save_file);
        }
        public void start (){
            load_list (save_file);
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
            _files.append (download_item);
            file_added (download_item);
            save_list (save_file);
            debug ("file added :");
        }
        public void remove_file (Model.IDownloadItem download_item){
            download_item.remove ();
            remove (download_item);
        }
        public void remove (Model.IDownloadItem download_item){
            _files.remove (download_item);
            file_removed (download_item);
            save_list (save_file);
            debug ("file removed, length "+get_length ().to_string ());
            
        }
        private void save_list (string filename){
            ValueArray va = new ValueArray (0);
            foreach (Model.IDownloadItem d_item in _files)
                if (d_item is Model.AriaHttp){
                    var val = Value (typeof(HashTable));
                    val = (d_item as Model.AriaHttp).get_ht ();
                    va.append (val);
                }
            
            var data = Soup.XMLRPC.build_method_response (va);
            
            Utils.save_string (save_file, data);
            debug ("list saved as :"+filename);
        }
        private void load_list (string filename){
            debug ("load list from :"+filename);
            var data = Utils.load_string (save_file);
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
                            }
                            //var finished_item=new FinishedItem (null);
                            //finished_item.xml_value=viter; //set xml_value to be processed by FinishedItem
                            //list.append (finished_item);
                        }
                    }
                }
            } catch (Error e){
                error ("cant loadlist : %s", e.message);
            }
        }
        //public signal void file_added(Model.IDownloadItem download_item);
        //public signal void file_removed(Model.IDownloadItem file);
    }
}
