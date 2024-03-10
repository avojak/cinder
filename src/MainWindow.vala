/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.MainWindow : Adw.ApplicationWindow {

    private Gtk.Stack base_stack;
    private Adw.OverlaySplitView overlay_split_view;
    private Cinder.WelcomeView welcome_view;

    private unowned Cinder.EmberMug? current_device;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            title: APP_NAME,
            width_request: 200,
            height_request: 360
        );
        add_action_entries ({
            
        }, this);
    }

    construct {
        if (APP_ID.has_suffix ("Devel")) {
            add_css_class("devel");
        }

        var app_menu = new GLib.Menu ();
        //  app_menu.append (_("Preferences"), "app.preferences");
        app_menu.append (_("About %s").printf (APP_NAME), "app.about");
        app_menu.append (_("Quit"), "app.quit");

        var menu = new GLib.Menu ();
        menu.append_section (null, app_menu);

        var menu_button = new Gtk.MenuButton () {
            icon_name = "open-menu-symbolic",
            menu_model = menu,
            tooltip_text = _("Menu")
        };

        var toggle_sidebar_button = new Gtk.ToggleButton () {
            icon_name = "sidebar-show-symbolic",
            tooltip_text = _("Toggle Device List")
        };

        var header_bar = new Adw.HeaderBar () {
            show_title = false
        };
        header_bar.pack_start (toggle_sidebar_button);
        header_bar.pack_end (menu_button);

        var device_view = new Cinder.DeviceControlView ();

        var toolbar_view = new Adw.ToolbarView () {
            content = device_view
        };
        toolbar_view.add_top_bar (header_bar);

        overlay_split_view = new Adw.OverlaySplitView () {
            sidebar = new Cinder.DeviceListView (),
            //  max_sidebar_width = 330,
            pin_sidebar = true,
            show_sidebar = false,
            content = toolbar_view
        };
        overlay_split_view.bind_property ("show_sidebar", toggle_sidebar_button, "active", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);

        var navigation_view = new Adw.NavigationView ();

        welcome_view = new Cinder.WelcomeView ();
        welcome_view.device_selected.connect (on_device_selected);

        base_stack = new Gtk.Stack ();
        base_stack.add_named (welcome_view, "welcome");
        base_stack.add_named (overlay_split_view, "overlay");

        set_content (base_stack);
        //  add_breakpoint (breakpoint);

        set_default_size (Cinder.Application.settings.window_width, Cinder.Application.settings.window_height);
        if (Cinder.Application.settings.window_maximized) {
            maximize ();
        }

        close_request.connect (() => {
            save_window_state ();
            return Gdk.EVENT_PROPAGATE;
        });

    }

    public void device_found (Cinder.EmberMug device) {
        welcome_view.device_found (device);
        device.notify["connected"].connect (() => {
            if (device.connected) {
                on_device_connected (device);    
            }
        });
        if (device.connected) {
            on_device_connected (device);
        }
    }

    public void device_removed (Cinder.EmberMug device) {
        welcome_view.device_removed (device);
        if (device == current_device) {
            on_device_disconnected ();
        }
    }

    public void device_disconnected (Cinder.EmberMug device) {
        //  welcome_view.device_removed (device);
        if (device == current_device) {
            on_device_disconnected ();
        }
    }

    private void save_window_state () {
        if (maximized) {
            Cinder.Application.settings.window_maximized = true;
        } else {
            Cinder.Application.settings.window_maximized = false;
            Cinder.Application.settings.window_width = get_size (Gtk.Orientation.HORIZONTAL);
            Cinder.Application.settings.window_height = get_size (Gtk.Orientation.VERTICAL);
        }
    }

    private void on_device_selected (Cinder.EmberMug device) {
        if (!device.paired) {
            device.attempt_pair.begin ((obj, res) => {
                if (device.attempt_pair.end (res)) {
                    device.attempt_connect.begin ();
                }
            });
        } else {
            device.attempt_connect.begin ();
        }
    }
    
    private void on_device_connected (Cinder.EmberMug device) {
        current_device = device;
        base_stack.set_visible_child_full ("overlay", Gtk.StackTransitionType.SLIDE_LEFT);

        // Request initial states when characteristics are registered
        // TODO: There's a race condition here, where the characteristics might already be registered
        //       by the time that this signal handler is connected.
        device.characteristic_ready.connect ((characteristic) => {
            switch (characteristic) {
                case Cinder.EmberMug.Characteristic.MUG_NAME:
                    device.read_mug_name ();
                    break;
                case Cinder.EmberMug.Characteristic.CURRENT_TEMPERATURE:
                    device.read_current_temperature ();
                    break;
                case Cinder.EmberMug.Characteristic.TARGET_TEMPERATURE:
                    device.read_target_temperature ();
                    break;
                case Cinder.EmberMug.Characteristic.TEMPERATURE_UNIT:
                    device.read_temperature_unit ();
                    break;
                case Cinder.EmberMug.Characteristic.LIQUID_LEVEL:
                    device.read_liquid_level ();
                    break;
                case Cinder.EmberMug.Characteristic.BATTERY:
                    device.read_battery_status ();
                    break;
                case Cinder.EmberMug.Characteristic.LIQUID_STATE:
                    device.read_liquid_state ();
                    break;
                //  case Cinder.EmberMug.Characteristic.VOLUME:
                //      device.read_volume ();
                //      break;
                //  case Cinder.EmberMug.Characteristic.LAST_LOCATION:
                //      device.read_last_location ();
                //      break;
                //  case Cinder.EmberMug.Characteristic.UUID_ACCELERATION:
                //      device.read_uuid_acceleration ();
                //      break;
                case Cinder.EmberMug.Characteristic.FIRMWARE:
                    device.read_firmware ();
                    break;
                //  case Cinder.EmberMug.Characteristic.MUG_ID:
                //      device.read_mug_id ();
                //      break;
                //  case Cinder.EmberMug.Characteristic.DSK:
                //      device.read_dsk ();
                //      break;
                //  case Cinder.EmberMug.Characteristic.UDSK:
                //      device.read_udsk ();
                //      break;
                //  case Cinder.EmberMug.Characteristic.CONTROL_REGISTER_ADDRESS:
                //      device.read_control_register_address ();
                //      break;
                //  case Cinder.EmberMug.Characteristic.CONTROL_REGISTER_DATA:
                //      device.read_control_register_data ();
                //      break;
                case Cinder.EmberMug.Characteristic.PUSH_EVENTS:
                    device.start_push_notifications ();
                    break;
                //  case Cinder.EmberMug.Characteristic.STATISTICS:
                //      device.read_statistics ();
                //      break;
                //  case Cinder.EmberMug.Characteristic.LED_COLOR:
                //      device.read_led_color ();
                //      break;
                default:
                    break;
            }
        });
    }

    private void on_device_disconnected () {
        current_device = null;
        base_stack.set_visible_child_full ("welcome", Gtk.StackTransitionType.UNDER_RIGHT);
    }

}