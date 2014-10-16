
namespace Arrive.Model{
    public enum WindowState {
        NORMAL = 0,
        MAXIMIZED
    }
    public class SavedState : Granite.Services.Settings {
        public int window_width {get; set;}
        public int window_height {get; set;}
        public WindowState window_state {get; set;}
        public string notebook_state {get; set;}
        public string search_string {get; set;}

        public SavedState (){
            base ("org.pantheon.arrive.saved-state");
        }
    }
    public enum FinishedAction{
        NOTHING = 0,
        SUSPEND,
        HIBERNATE,
        SHUTDOWN
    }
    public class Settings : Granite.Services.Settings {
        public int default_segment_num {get; set;}
        public FinishedAction finished_action {get; set;}
        public Settings (){
            base ("org.pantheon.arrive.settings");
        }
    }
}
