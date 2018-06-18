using Soup;
namespace Arrive.Model {
public static Aria2 aria2;
public class Aria2 : Object {
    private static int REFRESH_TIME = 500;
    public int num_active;
    public int num_waiting;
    public int num_stopped;
    public int download_speed;
    public int upload_speed;
    private string aria_ip = "http://localhost";
    private string aria_port = "6800";
    public string aria_uri;
    public bool is_listened;
    public DownloadList download_list;
    public FinishedList finished_list;

    public Aria2 (IDownloadList d_list, FinishedList f_list) {
        num_active = 0;
        num_waiting = 0;
        num_stopped = 0;
        download_speed = 0;
        upload_speed = 0;
        //if(ip==null)aria_ip="http://localhost" else aria_ip = ip;
        //if(port==null)aria_port="6800" else aria_port = port;
        aria_uri = aria_ip + ":" + aria_port + "/rpc";
        start_aria2c ();
        download_list = d_list as DownloadList;
        finished_list = f_list;
        get_global_option ();

        var refresh_timer = new TimeoutSource (REFRESH_TIME);
        refresh_timer.set_callback (() => {
            refresh_status ();
            return true;
        });
        refresh_timer.attach (null);
        debug ("using aria2 version = %s", get_version() );
    }
    ~Aria2 () {
        shutdown ();
    }
    public string add_uri (string uris, string dir, int split, bool pause = false) {
        var v_array = new ValueArray (0);
        v_array.append (uris);

        var option = new HashTable < string, Value ? > (str_hash, str_equal);
        option.insert ("dir", dir);

        if (split < 1) {
            split = 1;
        }

        option.insert ("split", split.to_string () );
        option.insert ("pause", pause.to_string () );

        Soup.Message msg = Soup.XMLRPC.request_new (aria_uri,
                           "aria2.addUri",
                           typeof (ValueArray), v_array,
                           typeof (HashTable), option
                                                   );
        var data = send_message (msg);

        try {
            Value v;

            if (Soup.XMLRPC.parse_method_response (data, -1, out v) ) {
                return v.get_string (); // return gid
            } else {
                warning ("error while add_uri2");
            }
        } catch (Error e) {
            warning ("error while add_uri " + e.message);
        }

        return "";
    }
    public string add_torrent (string torrent_path) {
        string encoded = encode64 (torrent_path);
        message (encoded);
        var byte = new GLib.ByteArray.take (encoded.data);
        Soup.Message msg = Soup.XMLRPC.request_new (Model.aria2.aria_uri,
                           "aria2.addTorrent",
                           typeof (GLib.ByteArray), byte
                                                   );

        if (msg == null) {
            return "";
        }

        var data = send_message (msg);

        try {
            Value v;

            if (Soup.XMLRPC.parse_method_response (data, -1, out v) ) {
                return v.get_string();//return gid
            } else {
                warning ("error while add_torrent2");
            }
        } catch (Error e) {
            warning ("error while add_uri " + e.message);
        }

        return "";
    }
    public string encode64 (string torrent_path) {
        string data = "";
        File save_file = File.new_for_path (torrent_path);

        if ( save_file.query_exists () ) { // check file exist
            try {
                var data_stream = new DataInputStream (save_file.read () );
                data = data_stream.read_upto ("", "".length, null);
                data = Base64.encode (data.data);
            } catch (Error e) {
                warning ("cant load string: %s", e.message);
            }
        } else {
            warning ("can't load string");
        }

        return data;
    }
    private void start_aria2c () {
        try {
            //max connection and split size are hardcoded for now
            //TODO:create preferences dialog to set max-connection-per-server
            //and min-split-size (and almost everything)
            string[] spawn_args = {
                "aria2c",
                "--enable-rpc",
                "--max-connection-per-server=16",
                "--min-split-size=1M",
                "--pause=true",
                "--enable-dht",
                "--dht-entry-point=dht.transmissionbt.com:6881",
                "--dht-listen-port=6881",
                "--disable-ipv6"
            };
            string[] spawn_env = Environ.get ();
            Pid child_pid;
            int standard_input;
            int standard_output;
            int standard_error;

            bool ret = Process.spawn_async_with_pipes (
                           null,
                           spawn_args,
                           spawn_env,
                           SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                           null,
                           out child_pid,
                           out standard_input,
                           out standard_output,
                           out standard_error
                       );
            // stdout:
            IOChannel output = new IOChannel.unix_new (standard_output);
            output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                return process_line (channel, condition, "stdout");
            });

            // stderr:
            IOChannel error = new IOChannel.unix_new (standard_error);
            error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                return process_line (channel, condition, "stderr");
            });

            /* if (!ret) */
            /*     return; */
            ChildWatch.add (child_pid, (pid, status) => {
                Process.close_pid (pid);
                Gtk.main_quit ();
            });
            is_listened = true;
        } catch (GLib.SpawnError error) {
            critical ("cant start aria2c %s", error.message);
        }

        //need to wait for aria to load
        Thread.usleep (500000);

        if (get_version () == "") {
            critical ("cant start or bind port, please restart and wait a few second before reruning Arrive");
            is_listened = false;
            shutdown ();
        }
    }
    private static bool process_line (IOChannel channel, IOCondition condition, string stream_name) {
        if (condition == IOCondition.HUP) {
            debug ("%s: The fd has been closed.\n", stream_name);
            return false;
        }

        try {
            string line;
            channel.read_line (out line, null, null);
            debug ("%s: %s", stream_name, line);
        } catch (Error e) {
            warning ("%s: ConvertError: %s\n", stream_name, e.message);
            return false;
        }

        return true;
    }
    public void pause (string gid) {
        Soup.Message msg = XMLRPC.request_new (aria_uri, "aria2.pause",
                                               typeof (string), gid);
        send_message (msg);
    }
    public void unpause (string gid) {
        Soup.Message msg = XMLRPC.request_new (aria_uri, "aria2.unpause",
                                               typeof (string), gid);
        send_message (msg);
    }
    public void remove (string gid) {
        Soup.Message msg = XMLRPC.request_new (aria_uri, "aria2.remove",
                                               typeof (string), gid);
        send_message (msg);
    }
    private void refresh_status () {
        refresh_active ();
        refresh_waiting ();
        refresh_stopped ();

        clean_finished ();
        download_list.item_refreshed ();
    }
    private void refresh_active (bool add_new_to_list = false) {
        Soup.Message msg = Soup.XMLRPC.request_new (aria_uri
                           , "aria2.tellActive");
        string data = send_message (msg);
        put_data_to_list (data);
    }
    private void refresh_waiting (bool add_new_to_list = false) {
        Soup.Message msg = Soup.XMLRPC.request_new (aria_uri
                           , "aria2.tellWaiting"
                           , typeof (int), 0,
                           typeof (int), 1000);
        string data = send_message (msg);
        put_data_to_list (data);
    }
    private void refresh_stopped (bool add_new_to_list = false) {
        Soup.Message msg = Soup.XMLRPC.request_new (aria_uri
                           , "aria2.tellStopped"
                           , typeof (int), 0
                           , typeof (int), 1000);
        string data = send_message (msg);
        put_data_to_list (data);
    }
    private void put_data_to_list (string data) {
        try {
            Value v;

            if (Soup.XMLRPC.parse_method_response (data, -1, out v) && v.holds (typeof (ValueArray) ) ) {
                unowned ValueArray va;
                va = (ValueArray) v;

                foreach (Value viter in va) {
                    if (viter.holds (typeof (HashTable) ) ) { // viter will hold download list xml
                        HashTable < string, Value ? > ht;
                        Value val;

                        ht = (HashTable < string, Value ? >) viter;
                        val = ht.get ("gid");
                        var gid = val.get_string ();

                        var d_item = download_list.get_by_gid (gid);

                        if ( d_item == null) {
                            //TODO:item that arent exist in download_list should be added to download_list
                            var aria_magnet = new Model.AriaMagnet ();
                            aria_magnet.update_by_ht (ht);

                            if (aria_magnet.info_hash != null && aria_magnet.info_hash != "") {
                                if (aria_magnet.status != "complete") {
                                    download_list.add_file (aria_magnet);
                                }
                            } else {
                                var aria_http = new Model.AriaHttp ();
                                aria_http.update_by_ht (ht);

                                if (aria_http.status != "complete") {
                                    download_list.add_file (aria_http);
                                }
                            }
                        } else {
                            //just update the content
                            if (d_item is AriaHttp) {
                                (d_item as AriaHttp).update_by_ht (ht);
                            } else if (d_item is AriaMagnet) {
                                (d_item as AriaMagnet).update_by_ht (ht);
                            }
                        }
                    }
                }
            }
        } catch (Error e) {
            warning ("error parsing method response");
        }
    }
    private void clean_finished () {
        List<IDownloadItem> finished_items = download_list.get_by_status ("complete");

        foreach (IDownloadItem finished_item in finished_items) {
            try {
                new Notify.Notification (finished_item.filename,
                                         "Download completed",
                                         "arrive.svg").show ();
            } catch (Error e) {
                warning (e.message);
            }

            if (finished_item is AriaHttp) {
                finished_list.append (finished_item);
                download_list.remove (finished_item);
            } else {
                //find the magnet that causing this download and merge
                foreach (Model.IDownloadItem dw_item in download_list.files) {
                    if (dw_item is AriaMagnet
                            && (dw_item as AriaMagnet).info_hash == (finished_item as AriaMagnet).info_hash) {
                        (dw_item as AriaMagnet).set_uri ( (finished_item as AriaMagnet).uris);
                        debug ("uris :" + (finished_item as AriaMagnet).uris);
                        (dw_item as AriaMagnet).set_name (finished_item.filename);
                        (dw_item as Model.AriaMagnet).change_gid (finished_item.gid);
                        finished_list.append (finished_item);
                        download_list.remove (finished_item);
                    }
                }

            }
        }
    }
    //TODO:Parse getGlobalOption response
    private void get_global_option () {
        Soup.Message msg = XMLRPC.request_new (aria_uri, "aria2.getGlobalOption");
        string data = send_message (msg);
    }
    private void get_global_stat () {
        Soup.Message msg = XMLRPC.request_new (aria_uri, "aria2.getGlobalStat");
        string data = send_message (msg);

        try {
            Value v;

            if (Soup.XMLRPC.parse_method_response (data, -1, out v) ) {
                HashTable < string, Value ? > ht;
                Value val;

                ht = (HashTable < string, Value ? >) v;

                val = ht.get ("numStopped");
                num_stopped = int.parse (val.get_string () );

                val = ht.get ("numWaiting");
                num_waiting = int.parse (val.get_string () );

                val = ht.get ("numActive");
                num_active = int.parse (val.get_string () );

                val = ht.get ("downloadSpeed");
                download_speed = int.parse (val.get_string () );

                val = ht.get ("uploadSpeed");
                upload_speed = int.parse (val.get_string () );
            }
        } catch (Error e) {
            warning ("Error while processing tellStatus response");
        }
    }
    public string get_version () {
        string version = "";
        Soup.Message msg = XMLRPC.request_new (aria_uri, "aria2.getVersion");
        string data = send_message (msg);

        try {
            Value v;

            if (Soup.XMLRPC.parse_method_response (data, -1, out v) ) {
                HashTable < string, Value ? > ht;
                Value val;

                ht = (HashTable < string, Value ? >) v;

                val = ht.get ("version");
                version = val.get_string ();
            }
        } catch (Error e) {
            warning ("Error while processing getVersion response");
        }

        return version;
    }
    public void shutdown () {
        Soup.Message msg = XMLRPC.request_new (aria_uri, "aria2.shutdown");
        send_message (msg);
    }
    private void force_shutdown () {
        Soup.Message msg = XMLRPC.request_new (aria_uri, "aria2.forceShutdown");
        send_message (msg);
    }
    //TODO:using system.multicall to call more than one method at once
    private void system_multicall () {
    }
    private string send_message (Soup.Message message) {
        string data = "";

        if (is_listened) {
            var session = new Session ();
            session.send_message (message);

            data = (string) message.response_body.flatten ().data;

            if (data == null) {
                is_listened = false;
                debug ("send_message return null");
            }
        }

        return data;
    }
}
}
