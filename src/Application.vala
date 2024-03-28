/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

 public class Cinder.Application : Adw.Application {

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { "about", on_about_activate },
        //  { "preferences", on_preferences_activate },
        { "quit", quit }
    };

    private static GLib.Once<Cinder.Application> instance;
    public static unowned Cinder.Application get_instance () {
        return instance.once (() => { return new Cinder.Application (); });
    }

    public static Cinder.Settings settings;

    private Cinder.MainWindow main_window;

    private Cinder.Bluetooth.Device? connected_device;

    static construct {
        settings = new Cinder.Settings ();
    }

    public Application () {
        Object (
            application_id: APP_ID
        );
    }

    protected override void activate () {
        // On a repeat invocation (e.g. clicking a notification), simply display the
        // existing window instead of creating a new one.
        if (main_window != null) {
            main_window.present ();
            return;
        }

        main_window = new Cinder.MainWindow (this);
        main_window.close_request.connect (() => {
            if (connected_device != null) {
                //  connected_device.disconnect.begin ((obj, res) => {
                //      try {
                //          connected_device.disconnect.end (res);
                //          debug ("Device disconnected");
                //      } catch (GLib.Error e) {
                //          warning (e.message);
                //      }
                //  });
            }
            return Gdk.EVENT_PROPAGATE;
        });
        main_window.show ();

        var device_manager = new Cinder.Bluetooth.EmberDeviceManager ();
        device_manager.device_found.connect ((mug) => {
            main_window.device_found (mug);
        });
        //  device_manager.device_found.connect ((device) => {
        //  });
        //  var manager = new Cinder.Bluetooth.ObjectManager ();
        //  manager.device_added.connect ((device) => {
        //      main_window.device_found (device);
        //  });
        //  manager.device_removed.connect ((device) => {
        //      main_window.device_removed (device);
        //  });
        //  manager.device_disconnected.connect ((device) => {
        //      main_window.device_disconnected (device);
        //  });
    }

    public override void startup () {
        base.startup ();

        add_action_entries (ACTION_ENTRIES, this);

        set_accels_for_action ("app.quit", { "<primary>q" });
    }

    private void on_about_activate () {
        var about_window = new Adw.AboutWindow () {
            transient_for = main_window,
            application_icon = APP_ID,
            application_name = APP_NAME,
            developer_name = DEVELOPER_NAME,
            version = VERSION,
            comments = _("Control your Ember® Mug"),
            website = "https://github.com/avojak/cinder",
            issue_url = "https://github.com/avojak/cinder/issues",
            developers = { "%s <%s>".printf (DEVELOPER_NAME, DEVELOPER_EMAIL) },
            designers = { "%s %s".printf (DEVELOPER_NAME, DEVELOPER_WEBSITE) },
            copyright = "© 2024 %s".printf (DEVELOPER_NAME),
            license_type = Gtk.License.GPL_3_0
        };
        about_window.add_legal_section ("Ember", "Cinder is not affiliated, associated, authorized, endorsed by, or in any way officially connected with Ember Technologies, or any of its subsidiaries or its affiliates. Ember® is a registered trademark of Ember Technologies, Inc.\n\nAll other product names mentioned herein, with or without the registered trademark symbol ® or trademark symbol ™; are generally trademarks and/or registered trademarks of their respective owners.", Gtk.License.UNKNOWN, null);
        about_window.add_credit_section (_("Related projects"), {
            "%s %s".printf ("Ember Mug Bluetooth Documentation", "https://github.com/orlopau/ember-mug"),
            "%s %s".printf ("Python Ember Mug", "https://github.com/sopelj/python-ember-mug")
        });
        about_window.present ();
    }

    //  private void on_preferences_activate () {
        //  var dialog = new Cinder.PreferencesDialog (main_window);
        //  dialog.close_request.connect (() => {
        //      // Ensure we don't have any lingering handlers for device connection changes
        //      dialog.dispose ();
        //      return true;
        //  });
        //  dialog.show ();
    //  }

    public static int main (string[] args) {
        var app = Cinder.Application.get_instance ();
        return app.run (args);
    }

}
