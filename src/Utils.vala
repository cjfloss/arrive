[DBus (name = "org.freedesktop.UPower")]
public interface UPower : GLib.Object {
    public abstract void Hibernate () throws GLib.IOError;
    public abstract bool HibernateAllowed () throws GLib.IOError;
    public abstract void Suspend () throws GLib.IOError;
    public abstract bool SuspendAllowed () throws GLib.IOError;
}
[DBus (name = "org.gnome.SessionManager")]
public interface GnomeSessionManager : GLib.Object {
    public abstract void Shutdown () throws GLib.IOError;
    public abstract bool CanShutdown () throws GLib.IOError;
}
public class Utils{
    public static bool save_string (string path, string data){
        try {
            File save_file = File.new_for_path (path);
            if(!save_file.get_parent ().query_exists ()) 
                save_file.get_parent ().make_directory_with_parents ();
            if(save_file.query_exists ())
                save_file.delete ();
        
            var file_stream = save_file.create (FileCreateFlags.NONE);
            var data_stream = new DataOutputStream (file_stream);
            if(data != null) data_stream.put_string (data);
            return true;
        } catch (Error e){
            error ("cant save :"+ path + e.message);
        }
    }
    public static string load_string (string path){
        string data = "";
        File save_file = File.new_for_path (path);
        if(save_file.query_exists ()) { //check file exist
            try {
                var data_stream = new DataInputStream (save_file.read ());
                data = data_stream.read_until ("", null);
            } catch (Error e){
                error ("cant load string: %s", e.message);
            }
        }else
            message ("can't load string");
        return data;
    }
    public static bool remove_file (string path){
        message ("remove "+path);
        File file = File.new_for_path (path);
        if (file.query_exists ()
            && file.query_file_type (0) != FileType.DIRECTORY){
            try{
                return file.delete ();
            }catch(Error e){
                debug ("cant remove file : "+path);
            }
        }
        return false;
    }
    public static bool trash_file (string path){
        File file = File.new_for_path (path);
        if (file.query_exists ()){
            try{
                return file.trash ();
            }catch(Error e){
                debug ("cant trash file : "+path);
            }
        }
        return false;
    }
    public static bool open_file (string path){
        var file = File.new_for_path (path);
        var handler = file.query_default_handler (null);
        var list = new List<File> ();
        list.append (file);
        return handler.launch (list, null);
    }
}
