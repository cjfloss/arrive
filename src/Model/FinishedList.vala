namespace Arrive.Model {
    public class FinishedList : Object {
        private File save_file = File.new_for_path (Environment.get_user_data_dir ()+"/arrive/finished_list.xml");
        public List<FinishedItem> list;
        public FinishedList (){
            load_list_from_file ();
            list_changed.connect (save_list_to_file);
        }
        public void append(DownloadItem download_item){
            var finished_item = new FinishedItem (download_item);
            list.append (finished_item);
            list_changed ();
        }
        private void save_list_to_file(){
            debug ("saving finishedlist file");
            //create ValueArray of all DownloadItem in list
            ValueArray va= new ValueArray (0);
            foreach(FinishedItem finished_item in list)
                va.append (finished_item.xml_value);
            //create xml string of valuearray using build method_response instead of using separate libxml2
            string data = Soup.XMLRPC.build_method_response (va);
            //save xmlstring
            if(!save_file.get_parent ().query_exists ()) save_file.get_parent ().make_directory_with_parents ();
            if(save_file.query_exists ())
                save_file.delete ();
            try {
                {
                    var file_stream = save_file.create (FileCreateFlags.NONE);
                    var data_stream = new DataOutputStream (file_stream);
                    if(data != null) data_stream.put_string (data);
                }
            } catch (Error e){
                error ("cant save finishedlist ; %s", e.message);
            }

        }
        private void load_list_from_file(){
            if(save_file.query_exists ()) { //check file exist
                try {
                    var data_stream = new DataInputStream (save_file.read ());
                    string data = data_stream.read_until ("", null);
                    try {
                        Value v;
                        if(Soup.XMLRPC.parse_method_response (data, -1, out v)
                           && v.holds (typeof(ValueArray))) { //get value from xml string
                            unowned ValueArray va;
                            va =(ValueArray) v;
                            foreach(Value viter in va) {
                                HashTable<string, Value ?> ht;
                                if(viter.holds (typeof(HashTable))) {
                                    var finished_item=new FinishedItem (null);
                                    finished_item.xml_value=viter; //set xml_value to be processed by FinishedItem
                                    list.append (finished_item);
                                }

                            }
                        }
                    } catch (Error e){
                        error ("cant parse finishedlist : %s", e.message);
                    }
                } catch (Error e){
                    error ("cant load downloadlist: %s", e.message);
                }
                list_changed ();
            }else
                message ("can't find finishedlist ");
            debug ("finished list loaded, list lenght %u", list.length ());
        }
        public signal void list_changed();
    }
}
