namespace Arrive.Model {
public class FinishedItem : Object {
    public Soup.Date date_finished {get; protected set;}
    public string date_compact {get; protected set;}
    public string filename;
    public string dir;
    private string _path;
    public unowned string path {
        get{
            _path = dir+"/"+filename;
            return _path;
        }
        protected set {
            _path = value;
        }}
    public uint64 total_length;
    public FinishedItem (IDownloadItem download_item) {
        filename = download_item.filename;
        dir = download_item.dir;
        _path = dir + "/" + filename;
        total_length = download_item.total_length;
        date_finished = new Soup.Date.from_now (0);
        date_compact= date_finished.to_string (Soup.DateFormat.ISO8601_COMPACT);
    }
    public FinishedItem.from_ht (HashTable<string, Value ?> ht) {
        set_ht (ht);
    }
    public void set_ht (HashTable<string, Value ?> ht) {
        Value val;

        val = ht.get ("filename");
        filename = val.get_string ();

        val = ht.get ("dir");
        dir = val.get_string ();

        _path = dir + "/" + filename;

        val = ht.get ("totalLength");
        total_length = uint64.parse (val.get_string ());

        val = ht.get ("dateFinished");
        var finished_string = val.get_string ();
        date_finished = new Soup.Date.from_string (finished_string);
        date_compact = date_finished.to_string (Soup.DateFormat.ISO8601_COMPACT);
    }
    public HashTable<string, Value ?> get_ht () {
        var finished_item = new HashTable<string, Value ?>(str_hash, str_equal);
        //FIXME:inserting some value causing corruption
        finished_item.insert ("filename", filename);
        finished_item.insert ("dir", dir);
        finished_item.insert ("totalLength", total_length.to_string ());
        //TODO:finished date should be saved
        finished_item.insert ("dateFinished", date_finished.to_string (Soup.DateFormat.ISO8601_COMPACT));
        return finished_item;
    }
    public void open_file () {
        Utils.open_file (dir + "/" + filename);
        message ("open file " + dir + "/" + filename);
    }
    public void open_folder () {
        Utils.open_file (dir);
    }
    public void move_to (string destination) {
        if (copy_to (destination)) {
            remove_file ();
            dir = destination;
        }
    }
    public bool copy_to (string destination) {
        try {
            File file = File.new_for_path (path);
            File dest = File.new_for_path (destination + "/" + filename);
            if (file != null && dest != null && !dest.query_exists ()) {
                file.copy_async.begin (dest, FileCopyFlags.NONE);
                return true;
            } else
                debug ("do not copy");
        } catch (Error e) {
            warning (e.message);
        }
        return false;
    }
    //FIXME: file copy doesnt work
    public void copy () {
        Gdk.Atom atom = Gdk.Atom.intern ("CLIPBOARD",false);
        var clipboard = Gtk.Clipboard.get (atom);

        Gtk.TargetEntry target0 = {"x-special/gnome-copied-files", 0, 0};
        Gtk.TargetEntry target1 = {"text/uri-list", 0, 0};

        Gtk.TargetEntry[] targets = {
            target0,
            target1
        };

        //clipboard.set_with_data (targets, (Gtk.ClipboardGetFunc) get_func, (Gtk.ClipboardClearFunc) clear_func);
    }
    public void remove_file () {
        Utils.remove_file (dir + "/" + filename);
    }
    public void trash_file () {
        Utils.trash_file (dir + "/" + filename);
    }
    public bool file_exist () {
        var file = File.new_for_path (dir + "/" + filename);
        return file.query_exists ();
    }
    private void get_func (Gtk.Clipboard clipboard, Gtk.SelectionData selection, uint info) {
        var data = "copy\n" + path;
        selection.set (selection.get_target (), 8, (uchar[]) data);
    }
    private void clear_func (Gtk.Clipboard clipboard) {
    }
    public string get_date_localized() {
        time_t date_t = date_finished.to_time_t ();
        var date = Date ();
        date.set_time_t (date_t);
        var date_c = new char[100];
        date.strftime (date_c, "%x");
        return (string)date_c;
    }
}
}
