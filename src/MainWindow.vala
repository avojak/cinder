/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.MainWindow : Adw.ApplicationWindow {

    private Gtk.Stack base_stack;
    private Adw.OverlaySplitView overlay_split_view;
    private Cinder.WelcomeView welcome_view;
    private Cinder.DeviceControlView device_control_view;

    private unowned Cinder.EmberMug? current_device;
    private Gtk.Revealer battery_revealer;
    private Gtk.Image battery_indicator;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            title: APP_NAME,
            width_request: 200,
            height_request: 360
        );
        add_action_entries ({
            { "led-color", on_led_color_button_clicked }
        }, this);
    }

    construct {
        if (APP_ID.has_suffix ("Devel")) {
            add_css_class("devel");
        }

        var device_menu = new GLib.Menu ();
        device_menu.append (_("Temperature Unit"), null);
        device_menu.append (_("Select LED Light Color…"), "win.led-color");
        //  var led_color_menu_item = new GLib.MenuItem ("LED Light Color", null);
        //  led_color_menu_item.set_icon (GLib.Icon.new_for_string ("circle-filled-symbolic"));
        //  device_menu.append_item (led_color_menu_item);

        var app_menu = new GLib.Menu ();
        //  app_menu.append (_("Preferences"), "app.preferences");
        app_menu.append (_("About %s").printf (APP_NAME), "app.about");
        app_menu.append (_("Quit"), "app.quit");

        var menu = new GLib.Menu ();
        menu.append_section (null, device_menu);
        menu.append_section (null, app_menu);

        var menu_button = new Gtk.MenuButton () {
            icon_name = "open-menu-symbolic",
            menu_model = menu,
            tooltip_text = _("Menu")
        };

        battery_indicator = new Gtk.Image.from_icon_name (null);
        battery_revealer = new Gtk.Revealer () {
            child = battery_indicator,
            reveal_child = false,
            transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT
        };

        var toggle_sidebar_button = new Gtk.ToggleButton () {
            icon_name = "sidebar-show-symbolic",
            tooltip_text = _("Toggle Device List")
        };

        var header_bar = new Adw.HeaderBar () {
            show_title = false
        };
        header_bar.pack_start (toggle_sidebar_button);
        header_bar.pack_start (battery_revealer);
        header_bar.pack_end (menu_button);

        device_control_view = new Cinder.DeviceControlView ();
        device_control_view.preset_selected.connect ((temperature) => {
            if (current_device == null) {
                return;
            }
            current_device.write_target_temperature (temperature);
        });

        var toolbar_view = new Adw.ToolbarView () {
            content = device_control_view
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
        //       by the time that this signal handler is connected. This can also happen if the device
        //       is paired, but not connected (i.e. the characteristics are all registered immediately,
        //       but the device is not connected until manually selected).
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
                    device.read_firmware_info ();
                    break;
                //  case Cinder.EmberMug.Characteristic.MUG_ID:
                //      device.read_mug_id ();
                //      break;
                case Cinder.EmberMug.Characteristic.DSK:
                    device.read_dsk ();
                    break;
                case Cinder.EmberMug.Characteristic.UDSK:
                    device.read_udsk ();
                    break;
                //  case Cinder.EmberMug.Characteristic.CONTROL_REGISTER_ADDRESS:
                //      device.read_control_register_address ();
                //      break;
                //  case Cinder.EmberMug.Characteristic.CONTROL_REGISTER_DATA:
                //      device.read_control_register_data ();
                //      break;
                case Cinder.EmberMug.Characteristic.PUSH_EVENTS:
                    device.start_push_notifications ();
                    break;
                case Cinder.EmberMug.Characteristic.STATISTICS:
                    // TODO: This is very noisy - only enable when in a debug mode
                    //  device.start_statistics_notifications ();
                    break;
                case Cinder.EmberMug.Characteristic.LED_COLOR:
                    device.read_led_color ();
                    break;
                default:
                    break;
            }
        });

        device.battery_status_changed.connect (update_battery_indicator);
        device.device_charging.connect (on_device_charging);
        device.device_not_charging.connect (on_device_not_charging);
        
        device.current_temperature_changed.connect (device_control_view.set_current_temperature);
        device.target_temperature_changed.connect ((temperature) => {
            if (device.liquid_level == Cinder.EmberMug.LiquidLevel.EMPTY) {
                return;
            }
            //  device_control_view.show_temperature_controls ();
        });
        device.temperature_unit_changed.connect ((unit) => {
            // TODO
        });

        device.liquid_level_changed.connect ((liquid_level) => {
            if (device.liquid_level == Cinder.EmberMug.LiquidLevel.EMPTY) {
                device_control_view.device_empty ();
            } else {
                device_control_view.device_not_empty ();
            }
        });
        device.liquid_state_changed.connect ((liquid_state) => {
            switch (liquid_state) {
                case Cinder.EmberMug.LiquidState.STABLE_TEMPERATURE:
                    on_target_temperature_reached ();
                    break;
                default:
                    warning ("Unahndled liquid state: %s", liquid_state.to_string ());
                    break;
            }
        });

        // Read initial status
        //  device.read_mug_name ();
        //  device.read_current_temperature ();
        //  device.read_target_temperature ();
        //  device.read_temperature_unit ();
        //  device.read_liquid_level ();
        //  device.read_battery_status ();
        //  device.read_liquid_state ();
        //  device.read_firmware ();
        //  device.start_push_notifications ();
        //  device.read_led_color ();
    }

    private void update_battery_indicator (Cinder.EmberMug.BatteryStatus battery_status) {
        var icon_name = "battery-level-%s-symbolic";
        if (battery_status.percent_charged <= 5) {
            icon_name = icon_name.printf ("0");
        } else if (battery_status.percent_charged > 5 && battery_status.percent_charged <= 15) {
            icon_name = icon_name.printf ("10");
        } else if (battery_status.percent_charged > 15 && battery_status.percent_charged <= 25) {
            icon_name = icon_name.printf ("20");
        } else if (battery_status.percent_charged > 25 && battery_status.percent_charged <= 35) {
            icon_name = icon_name.printf ("30");
        } else if (battery_status.percent_charged > 35 && battery_status.percent_charged <= 45) {
            icon_name = icon_name.printf ("40");
        } else if (battery_status.percent_charged > 45 && battery_status.percent_charged <= 55) {
            icon_name = icon_name.printf ("50");
        } else if (battery_status.percent_charged > 55 && battery_status.percent_charged <= 65) {
            icon_name = icon_name.printf ("60");
        } else if (battery_status.percent_charged > 65 && battery_status.percent_charged <= 75) {
            icon_name = icon_name.printf ("70");
        } else if (battery_status.percent_charged > 75 && battery_status.percent_charged <= 85) {
            icon_name = icon_name.printf ("80");
        } else if (battery_status.percent_charged > 85 && battery_status.percent_charged <= 95) {
            icon_name = icon_name.printf ("90");
        } else if (battery_status.percent_charged > 95) {
            icon_name = "battery-full-symbolic";
        }
        if (battery_status.charging) {
            icon_name = icon_name.replace ("symbolic", "charging-symbolic");
        }
        battery_indicator.icon_name = icon_name;
        battery_indicator.tooltip_text = "%i%% charged".printf (battery_status.percent_charged);

        if (!battery_revealer.child_revealed) {
            battery_revealer.set_reveal_child (true);
        }
    }

    private void on_device_charging () {
        if (battery_indicator.icon_name.contains ("charging")) {
            return;
        }
        battery_indicator.icon_name = battery_indicator.icon_name.replace ("symbolic", "charging-symbolic");
    }

    private void on_device_not_charging () {
        if (!battery_indicator.icon_name.contains ("charging")) {
            return;
        }
        battery_indicator.icon_name = battery_indicator.icon_name.replace ("charging-symbolic", "symbolic");
    }

    private void on_device_disconnected () {
        current_device = null;
        base_stack.set_visible_child_full ("welcome", Gtk.StackTransitionType.UNDER_RIGHT);
    }

    private void on_led_color_button_clicked () {
        var dialog = new Cinder.ColorChooserDialog (this, current_device.led_color);
        dialog.color_selected.connect ((color) => {
            debug (color.to_string ());
        });
        dialog.present ();
        //  var dialog = new Gtk.ColorDialog () {
        //      with_alpha = false
        //  };
        //  dialog.choose_rgba.begin (this, null, null, (obj, res) => {
        //      try {
        //          dialog.choose_rgba.end (res);
        //      } catch (GLib.Error e) {
        //          warning (e.message);
        //      }
        //  });
    }

    private void on_target_temperature_reached () {
        if (current_device == null) {
            return;
        }
        
        // Don't send the system notification if the window is currently in focus
        if (is_active) {
            return;
        }

        // TODO: Don't send the notification again until the target temperature has changed

        var notification = new GLib.Notification (_("Your drink is ready!"));
        notification.set_body (_("%s has reached the ideal temperature of %i°").printf (current_device.device.alias, current_device.target_temperature));
        application.send_notification ("temperature-reached", notification);
    }

}