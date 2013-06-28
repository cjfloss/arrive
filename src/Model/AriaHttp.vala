namespace Arrive.Model {
    public class AriaHttp : Object, IDownloadItem {
        public AriaHttp (){
            this.item_type = "AriaHttp";
        }
        public AriaHttp.with_attribute (string uris, string dir, int split, bool pause = true){
            this.item_type = "AriaHttp";
            this.uris = uris;
            this.dir = dir;
            this.connections = split;
            
            this.gid = Model.aria2.add_uri (uris, dir, connections, pause);
        }
        public AriaHttp.with_ht (HashTable<string, Value ?> ht){
            this.item_type = "AriaHttp";
            update_by_ht (ht);
            
            bool pause = true;
            if (this.status == "active")
                pause = false;
            this.gid = Model.aria2.add_uri (this.uris, this.dir, this.connections, pause);
            
        }
        public string gid {get; protected set;}
        public string item_type {get; protected set;}
        public string filename {get; protected set;}
        public string uris {get; protected set;}
        public string dir {get; protected set;}
        public string status {get; protected set;}
        public uint64 total_length {get; protected set;}
        public uint64 completed_length {get; protected set;}
        public uint download_speed {get; protected set;}
        public uint upload_speed {get; protected set;}
        public int connections {get;private set;}
        public void start (){
            //gid = Model.aria2.add_uri (uris, dir, connections, true);
            unpause ();
        }
        public void pause (){
            aria2.pause (gid);
        }
        public void unpause (){
            message (gid.to_string ());
            aria2.unpause (gid);
        }
        public void remove (){
            aria2.pause (gid);
            aria2.remove (gid);
            Utils.remove_file (dir+"/"+filename);
            Utils.remove_file (dir+"/"+filename+".aria2");
        }
        public void cancel (){
        }
        public void update_by_ht (HashTable<string, Value ?> ht){
            if (status != null && get_string_from_ht (ht, "status") != "active"){
                status = get_string_from_ht (ht, "status");  
                download_speed = int.parse (get_string_from_ht (ht, "downloadSpeed"));
                upload_speed = int.parse (get_string_from_ht (ht, "uploadSpeed"));              
                return;
            }
            
            Value val = Value (typeof(string));
            gid = get_string_from_ht (ht, "gid");
            total_length = uint64.parse (get_string_from_ht (ht, "totalLength"));
            completed_length = uint64.parse (get_string_from_ht (ht, "completedLength"));
            download_speed = int.parse (get_string_from_ht (ht, "downloadSpeed"));
            upload_speed = int.parse (get_string_from_ht (ht, "uploadSpeed"));
            dir = get_string_from_ht (ht, "dir");
            connections = int.parse (get_string_from_ht (ht, "connections"));

            val = ht.get ("files");
            if(val.holds (typeof(ValueArray))) {
                unowned ValueArray va;
                va=(ValueArray) val; //va contains array
                if(va.n_values > 0) {
                    Value vhtable=va.get_nth (0); //we choose the first array member
                    HashTable<string, Value ?> htable=(HashTable<string, Value ?>)vhtable; //extract hashtable from v
                    var path = parse_filename (get_string_from_ht (htable, "path"));

                    Value vuris = htable.get ("uris");
                    ValueArray _uris = new ValueArray (0);
                    var duris = ((ValueArray) vuris).copy ();
                    foreach(Value vuri in duris) {
                        var hturi= (HashTable<string, Value ?>)vuri;
                        _uris.append (get_string_from_ht (hturi, "uri"));
                        this.uris = get_string_from_ht (hturi, "uri");
                    }
                    if(path != "")
                        filename = path;
                    else
                        filename = parse_filename (_uris.get_nth (0).get_string ());
                }
            }else
                filename=_("cant get filename");
            
            status = get_string_from_ht (ht, "status");
        }
        public HashTable<string, Value ?> get_ht (){
            var ht = new HashTable<string, Value ?>(str_hash, str_equal);
            Value val = Value(typeof(string));
            
            val.set_string (gid);
            ht.insert("gid",val);
            
            val.set_string (item_type);
            ht.insert("item_type",val);
            val.set_string (total_length.to_string ());
            ht.insert ("totalLength", val);
            val.set_string (completed_length.to_string ());
            ht.insert ("completedLength", val);
            val.set_string (dir);
            ht.insert ("dir", val);
            val.set_string (connections.to_string ());
            ht.insert ("connections", val);
            
            //create the frustating files Value Array
            val = Value(typeof(ValueArray));
            var va = new ValueArray(0);
            val = va;
            //http download only consist of one file
            var vhtable = Value (typeof(HashTable));
            var htable = new HashTable<string, Value ?> (str_hash, str_equal);
            Value vfiles = Value (typeof(string));
            vfiles.set_string (dir+"/"+filename);
            htable.insert("path", vfiles);
            //FIXME:uris should be consist of a few uri
            Value vuris = Value (typeof (ValueArray));
            ValueArray duris = new ValueArray (0);
            Value vuri = Value(typeof(HashTable));
            var hturi = new HashTable<string, Value ?> (str_hash, str_equal);
            hturi.insert("uri",uris);
            vuri = hturi;
            duris.append (vuri);
            vuris = duris;
            htable.insert("uris", vuris);
            
            vhtable = htable;
            va.append (htable);//append the one and only file
            val = va;
            ht.insert("files", val);
            
            val = Value(typeof(string));
            val.set_string (status);
            ht.insert ("status", val);
            
            return ht;
        }
        public Value get_value (){
            var val = Value(typeof(string));
            return val;
        }
        public void set_value (Value value){
        }
        private string get_string_from_ht(HashTable<string, Value?> ht, string key){
            if (ht.get (key) != null){
                Value val = ht.get (key);
                return val.get_string ();
            }else
                return "";
        }
        private string parse_filename(string path){
            if (path != null && path != "") {
                string[] array = path.split ("/");
                var fn = array[array.length-1];
                return fn;
            }
            return "";
        }
    }
}
