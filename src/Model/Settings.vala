
namespace Arrive.Model {
public enum WindowState {
    NORMAL = 0,
    MAXIMIZED
}

public class SavedState {
    private GLib.Settings schema;
    public int window_width {
        get {return schema.get_int ("window-width");}
        set {schema.set_int ("window-width", value);}
    }
    public int window_height {
        get {return schema.get_int ("window-height");}
        set {schema.set_int ("window-height", value);}
    }
    public WindowState window_state {
        //FIXME: cant read from gconfig
        get {return (WindowState) schema.get_int ("window-state");}
        set {schema.set_int ("window-state", (int) value);}
    }
    public string notebook_state {
        get {
            return "downloading_list";
        }
        set {schema.set_string ("notebook-state", value);}
    }
    public string search_string {
        //FIXME: cant read from gconfig
        get {return "";}
        set {schema.set_string ("search-string", value);}
    }

    public SavedState () {
        schema = new GLib.Settings ("com.github.cjfloss.arrive.saved-state");
    }
}

public enum FinishedAction {
    NOTHING = 0,
    SUSPEND,
    HIBERNATE,
    SHUTDOWN
}
public class Settings : Object {
    private GLib.Settings schema;
    public int default_segment_num {
        get {return schema.get_int ("default-segment-num");}
        set {schema.set_int ("default-segment-num", value);}
    }
    public FinishedAction finished_action {get; set;}
    public Settings () {
        schema = new GLib.Settings ("com.github.cjfloss.arrive.settings");
    }
}
}
