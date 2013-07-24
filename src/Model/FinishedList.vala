namespace Arrive.Model {
    public class FinishedList : Object {
        private string save_path = Environment.get_user_data_dir ()+"/Arrive/finished_list.xml";
        private File save_file = File.new_for_path (Environment.get_user_data_dir ()+"/Arrive/finished_list.xml");
        public List<FinishedItem> list;
        public FinishedList (){
            load_list_from_file ();
            list_changed.connect (save_list_to_file);
        }
        public void append(IDownloadItem download_item){
            var finished_item = new FinishedItem (download_item);
            list.append (finished_item);
            list_changed ();
        }
        public void forget (FinishedItem f_item){
            list.remove (f_item);
            list_changed ();
        }
        public void remove (FinishedItem f_item){
            f_item.remove_file ();
            forget (f_item);
        }
        public void trash (FinishedItem f_item){
            f_item.trash_file ();
            forget (f_item);
        }
        public void copy_to (FinishedItem f_item, string destination){
            f_item.copy_to (destination);
            list_changed ();
        }
        public void move_to (FinishedItem f_item, string destination){
            f_item.move_to (destination);
            list_changed ();
        }
        private void save_list_to_file(){
            debug ("saving finishedlist file");
            //create ValueArray of all DownloadItem in list
            ValueArray va= new ValueArray (0);
            foreach(FinishedItem finished_item in list){
                var vht = Value (typeof(HashTable));
                vht = finished_item.get_ht ();
                va.append (vht);
            }
            //create xml string of valuearray using build method_response instead of using separate libxml2
            string data = Soup.XMLRPC.build_method_response (va);
            Utils.save_string (save_path, data);
        }
        private void load_list_from_file(){
            string data = Utils.load_string (save_path);
            try {
                Value v;
                if(Soup.XMLRPC.parse_method_response (data, -1, out v)
                   && v.holds (typeof(ValueArray))) { //get value from xml string
                    unowned ValueArray va;
                    va =(ValueArray) v;
                    foreach(Value viter in va) {
                        HashTable<string, Value ?> ht;
                        if(viter.holds (typeof(HashTable))) {
                            ht = (HashTable<string, Value ?>) viter;
                            var finished_item=new FinishedItem.from_ht (ht);
                            //finished_item.xml_value=viter; //set xml_value to be processed by FinishedItem
                            if (finished_item.file_exist ())
                                list.append (finished_item);
                        }

                    }
                }
                list_changed ();
            } catch (Error e){
                error ("cant parse finishedlist : %s", e.message);
            }
            debug ("finished list loaded, list lenght %u", list.length ());
        }
        public signal void list_changed();
    }
}
