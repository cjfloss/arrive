namespace Arrive.Model {
    public class FinishedItem : Object {
        private Soup.Date _date_finished;
        public Soup.Date date_finished {
            get{
                return _date_finished;
            }
            private set{}
        }
        private string _date_compact;
        public string date_compact {
            get{
                return _date_compact;
            }
            private set{
            }
        }
        private Value _xml_value;
        //used for saving and loading finished list
        public Value xml_value {
            get{
                var finished_item=new HashTable<string, Value ?>(str_hash, str_equal);
                //FIXME:inserting some value causing corruption
                finished_item.insert ("filename", filename);
                finished_item.insert ("dir", dir);
                finished_item.insert ("totalLength", total_length.to_string ());
                //TODO:finished date should be saved
                finished_item.insert ("dateFinished", _date_finished.to_string (Soup.DateFormat.ISO8601_COMPACT));;
                _xml_value=finished_item;
                return _xml_value; //return the value
            }
            set{
                _xml_value=value;
                if(_xml_value.holds (typeof(HashTable))) {
                    HashTable<string, Value ?> ht;
                    Value val;
                    ht = (HashTable<string, Value ?>)_xml_value;

                    val=ht.get ("filename");
                    filename=val.get_string ();

                    val=ht.get ("dir");
                    dir=val.get_string ();

                    val=ht.get ("totalLength");
                    total_length=uint64.parse (val.get_string ());

                    val=ht.get ("dateFinished");
                    var finished_string = val.get_string ();
                    _date_finished=new Soup.Date.from_string (finished_string);
                    _date_compact= _date_finished.to_string (Soup.DateFormat.ISO8601_COMPACT);
                }

            }
        }
        public string filename;
        private string dir;
        public unowned string path {
            get{
                return dir;
            }
            private set{}
        }
        public uint64 total_length;

        public FinishedItem (DownloadItem ? download_item){
            _xml_value= Value (typeof(HashTable));
            filename="";
            dir="";
            total_length=0;
            _date_finished=new Soup.Date.from_now (0);
            _date_compact= _date_finished.to_string (Soup.DateFormat.ISO8601_COMPACT);
            if(download_item != null) {
                filename=download_item.filename;
                dir=download_item.dir;
                total_length=download_item.total_length;
            }
        }
        //FIXME:it should be localized as what it named
        public string get_date_localized(){
            time_t date_t = _date_finished.to_time_t ();
            var date = Date ();
            date.set_time_t (date_t);
            return "%u-%u-%u".printf (date.get_day (), date.get_month (), date.get_year ());
        }
    }
}
