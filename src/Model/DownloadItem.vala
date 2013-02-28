using Granite.Services;
using Soup;
public class Arrive.Model.DownloadItem:Object {
//~     public DownloadType tipe{get;set;}
    public string status{get;set;default="";}
    private string _gid;
    public  string gid{
        get{return _gid;}
        set{
            _gid = value;
            //refresh_status();
        }
    }
    public  string filename{get;set;}
    public  string dir{get;set;}
    public  uint64 total_length{get;set;}
    public  uint64 completed_length{get;set;}
    public  int download_speed{get;set;default=0;}
    public  int upload_speed{get;set;default=0;}
    public int num_pieces{get;set;}
    public int connections{get;set;}
    private ValueArray _uris;
    public  ValueArray uris{
        get{
            return _uris;
            }
        set{
            _uris=value.copy();
        }}
    private Value _xml_value;
    public Value xml_value{
        get{
            return _xml_value;
        }
        set{
            _xml_value=value;
            if(_xml_value.holds(typeof(HashTable))) {
                HashTable<string,Value?> ht;
                Value val;

                ht = (HashTable<string,Value?>) _xml_value;

                val=ht.get("gid");
                gid=val.get_string();

                val=ht.get("totalLength");
                total_length=uint64.parse(val.get_string());

                val = ht.get("completedLength");
                if(val.holds(typeof(string))){
                    completed_length=uint64.parse(val.get_string());
                }

                val = ht.get("downloadSpeed");
                download_speed=int.parse(val.get_string());

                val = ht.get("uploadSpeed");
                upload_speed=int.parse(val.get_string());

                val = ht.get("dir");
                dir = val.get_string();

                val = ht.get("connections");
                connections = int.parse(val.get_string());

                val = ht.get("files");
                if(val.holds(typeof(ValueArray))){
                    unowned ValueArray va;
                    va=(ValueArray) val;//va contains array
                    if(va.n_values > 0){
                        Value vhtable=va.get_nth(0);//we choose the first array member
                        HashTable<string,Value?> htable=(HashTable<string,Value?>)vhtable;//extract hashtable from v
                        Value vfiles=htable.get("path");//find path in hashtable
                        var path = vfiles.get_string();
                        filename = parse_filename(path);
                        //TODO: fillin _uris so can be used by downloadlist.load_save_file
                        Value vuris = htable.get("uris");
                        var duris = ((ValueArray) vuris).copy();
                        foreach(Value vuri in duris){
                            var hturi= (HashTable<string,Value?>) vuri;
                            Value duri = hturi.get("uri");
                            _uris.append(duri.get_string());
                        }
                    }
                }else {
                    filename=_("cant get filename");
                }

                val = ht.get("status");
                status = val.get_string();
            }else{
                Granite.Services.Logger.notification("cant parse_method_response");
                //stdout.printf(data+"\n");
            }
        }
    }
    public DownloadItem() {
        _uris=new ValueArray(0);
//~         tipe=DownloadType.URI;
//~         status=Status.WAITING;
    }
    public void start(HashTable? options){
        Soup.Message msg;
        debug("start");
        if (options!=null){
            msg = XMLRPC.request_new(Arrive.App.aria2.aria_uri,"aria2.addUri",typeof(ValueArray),_uris,typeof(HashTable),options);
        }else{
            msg = XMLRPC.request_new(Arrive.App.aria2.aria_uri,"aria2.addUri",typeof(ValueArray),_uris);
        }
        string data = send_message (msg);
        stdout.printf(data);
        try {
            Value v = Value(typeof(string));
            if(XMLRPC.parse_method_response(data, -1, out v)) {
                string _gid;
                if(v.holds(typeof(string))){
                    _gid = v.get_string();
                    Granite.Services.Logger.notification("added gid = %s \n".printf(gid));
                    this.gid=_gid;
                }
            }else{
                debug("cant parse_method_response");
            }
        } catch(Error e) {
            debug("Error while processing addUri response");
        }
    }
    public void remove_download_result(){
        Soup.Message msg = XMLRPC.request_new(Arrive.App.aria2.aria_uri,"aria2.removeDownloadResult",typeof(string),gid);
        send_message (msg);
        //debug(data);
        //refresh_status();
    }
    public void pause(){
        Soup.Message msg = XMLRPC.request_new(Arrive.App.aria2.aria_uri,"aria2.pause",typeof(string),gid);
        send_message (msg);
        //refresh_status();
    }
    public void unpause(){
        Soup.Message msg = XMLRPC.request_new(Arrive.App.aria2.aria_uri,"aria2.unpause",typeof(string),gid);
        send_message (msg);
        //refresh_status();
    }
//~     public void tell_status(Value v){
//~             if(v.holds(typeof(HashTable))) {
//~                 HashTable<string,Value?> ht;
//~                 Value val;
//~ 
//~                 ht = (HashTable<string,Value?>) v;
//~ 
//~                 val=ht.get("gid");
//~                 gid=val.get_string();
//~ 
//~                 val=ht.get("totalLength");
//~                 total_length=uint64.parse(val.get_string());
//~ 
//~                 val = ht.get("completedLength");
//~                 if(val.holds(typeof(string))){
//~                     completed_length=uint64.parse(val.get_string());
//~                 }
//~ 
//~                 val = ht.get("downloadSpeed");
//~                 download_speed=int.parse(val.get_string());
//~ 
//~                 val = ht.get("uploadSpeed");
//~                 upload_speed=int.parse(val.get_string());
//~ 
//~                 val = ht.get("dir");
//~                 dir = val.get_string();
//~ 
//~                 val = ht.get("connections");
//~                 connections = int.parse(val.get_string());
//~ 
//~                 val = ht.get("files");
//~                 if(val.holds(typeof(ValueArray))){
//~                     unowned ValueArray va;
//~                     va=(ValueArray) val;//va contains array
//~                     if(va.n_values > 0){
//~                         Value vhtable=va.get_nth(0);//we choose the first array member
//~                         HashTable<string,Value?> htable=(HashTable<string,Value?>)vhtable;//extract hashtable from v
//~                         Value vfiles=htable.get("path");//find path in hashtable
//~                         var path = vfiles.get_string();
//~                         filename = parse_filename(path);
//~                     }
//~                 }else {
//~                     filename=_("cant get filename");
//~                 }
//~ 
//~                 val = ht.get("status");
//~                 status = val.get_string();
//~             }else{
//~                 Granite.Services.Logger.notification("cant parse_method_response");
//~                 //stdout.printf(data+"\n");
//~             }

//~     }
    private string parse_filename(string path){
        if (path!=null && path!=""){
            string[] array = path.split("/");
            var fn = array[array.length-1];
            return fn;
        }
        return "";
    }
    private string send_message(Soup.Message msg) {
        var session = new Soup.SessionSync();
        session.send_message(msg);
        string data = (string) msg.response_body.flatten().data;
        return data;
    }
}
