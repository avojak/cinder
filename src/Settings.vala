/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

 public class Cinder.Settings : GLib.Settings {

    public Settings () {
        Object (schema_id: APP_ID);
    }

    public bool window_maximized {
        get { return get_boolean ("window-maximized"); }
        set { set_boolean ("window-maximized", value); }
    }

    public int window_width {
        get { return get_int ("window-width"); }
        set { set_int ("window-width", value); }
    }

    public int window_height {
        get { return get_int ("window-height"); }
        set { set_int ("window-height", value); }
    }

    public int default_temperature {
        get { return get_int ("default-temperature"); }
        set { set_int ("default-temperature", value); }
    }

    public Cinder.EmberMug.TemperatureUnit temperature_unit {
        get { return get_int ("temperature-unit"); }
        set { set_int ("temperature-unit", value); }
    }

    public string temperature_presets {
        owned get { return get_string ("temperature-presets"); }
        set { set_string ("temperature-presets", value); }
        //  get {
        //      Gee.Map<string, int> presets = new Gee.HashMap<string, int> ();
        //      var value = get_string ("temperature-presets");
        //      var preset_strings = value.split (",");
        //      foreach (var preset_string in preset_strings) {
        //          var tokens = preset_string.split (":");
        //          presets.set (tokens[0], int.parse (tokens[1]));
        //      }
        //      return presets;
        //  }
        //  set {
        //      var sb = new GLib.StringBuilder ();
        //      foreach (var entry in value.entries) {
        //          sb.append ();
        //      }
        //      set_string ("temperature-presets", value);
        //  }
    }

}