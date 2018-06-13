using Soup;
namespace Arrive.Model {
public class DownloadItem : Object {
    public string status {get; set; default = ""; }
    private string _gid;
    public string gid {
        get {return _gid; }
        set {
            _gid = value;
        }
    }
    public string filename {get; set; }
    public string dir {get; set; }
    public uint64 total_length {get; set; }
    public uint64 completed_length {get; set; }
    public int download_speed {get; set; default = 0; }
    public int upload_speed {get; set; default = 0; }
    public int num_pieces {get; set; }
    public int connections {get; set; }
    private ValueArray _uris;
    public ValueArray uris {
        get{
            return _uris;
        }
        set{
            _uris = value.copy ();
        }
    }
    public DownloadItem () {
        _uris = new ValueArray (0);
    }
    public void start (HashTable ? options) {
        Soup.Message msg;
        debug ("start");
        if (options != null)
            msg = XMLRPC.request_new (aria2.aria_uri, "aria2.addUri",
                                      typeof (ValueArray), _uris,
                                      typeof (HashTable), options);
        else {
            msg = XMLRPC.request_new (aria2.aria_uri, "aria2.addUri", typeof (ValueArray), _uris);
        }
        string data = send_message (msg);
        stdout.printf (data);
        try {
            Value v = Value (typeof (string) );
            if (XMLRPC.parse_method_response (data, -1, out v) ) {
                string _gid;
                if (v.holds (typeof (string) ) ) {
                    _gid = v.get_string ();
                    debug ("added gid = %s \n".printf (_gid) );
                    this.gid = _gid;
                }
            } else {
                debug ("cant parse_method_response");
            }
        } catch (Error e) {
            debug ("Error while processing addUri response");
        }
    }
    public void remove () {
        Soup.Message msg = XMLRPC.request_new (aria2.aria_uri, "aria2.remove", typeof (string), gid);
        send_message (msg);
        //~         aria2.download_list.list_changed();
        //debug(data);
        //refresh_status();
    }
    public void remove_download_result () {
        Soup.Message msg = XMLRPC.request_new (aria2.aria_uri, "aria2.removeDownloadResult",
                                               typeof (string), gid);
        send_message (msg);
        //~         aria2.download_list.list_changed();
        //debug(data);
        //refresh_status();
    }
    public void pause () {
        Soup.Message msg = XMLRPC.request_new (aria2.aria_uri, "aria2.pause",
                                               typeof (string), gid);
        send_message (msg);
    }
    public void unpause () {
        Soup.Message msg = XMLRPC.request_new (aria2.aria_uri, "aria2.unpause",
                                               typeof (string), gid);
        send_message (msg);
    }
    public string to_string () {
        return "gid : " + gid +
               "\n filename : " + filename +
               "\n status : " + status +
               "\n dir : " + dir +
               "\n";
    }
    private string parse_filename (string path) {
        if (path != null && path != "") {
            string[] array = path.split ("/");
            var fn = array[array.length - 1];
            return fn;
        }
        return "";
    }
    private string send_message (Soup.Message msg) {
        var session = new Soup.Session ();
        session.send_message (msg);
        string data = (string) msg.response_body.flatten ().data;
        return data;
    }
}
}
