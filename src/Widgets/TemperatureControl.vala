/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.TemperatureControl : Gtk.Box {

    public int value { get; set; }

    private Gtk.Label temperature_label;
    private GLib.Thread<void> long_press_updates_thread;
    private GLib.Cancellable long_press_updates_cancellable = new GLib.Cancellable ();

    public TemperatureControl (int initial_value) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            halign: Gtk.Align.CENTER,
            spacing: 24,
            margin_bottom: 16,
            margin_end: 32,
            value: initial_value
        );
    }

    construct {
        var minus_button = new Gtk.Button.from_icon_name ("list-remove-symbolic") {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        minus_button.add_css_class ("flat");
        minus_button.add_css_class ("circular");

        var minus_press_controller = new Gtk.GestureClick ();
        minus_press_controller.set_propagation_phase (Gtk.PropagationPhase.CAPTURE);
        minus_press_controller.pressed.connect (() => {
            if (value <= Cinder.Application.settings.temperature_unit.get_minimum_temperature ()) {
                return;
            }
            value--;
            update_temperature_label ();
            value_changed (value);
        });

        var minus_long_press_controller = new Gtk.GestureLongPress ();
        minus_long_press_controller.set_propagation_phase (Gtk.PropagationPhase.CAPTURE);
        minus_long_press_controller.end.connect (() => {
            stop_long_press_updates ();
        });
        minus_long_press_controller.pressed.connect (() => {
            start_long_press_updates (() => {
                if (value <= Cinder.Application.settings.temperature_unit.get_minimum_temperature ()) {
                    return;
                }
                value--;
            });
        });

        minus_button.add_controller (minus_press_controller);
        minus_button.add_controller (minus_long_press_controller);
        
        var plus_button = new Gtk.Button.from_icon_name ("list-add-symbolic") {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        plus_button.add_css_class ("flat");
        plus_button.add_css_class ("circular");

        var plus_press_controller = new Gtk.GestureClick ();
        plus_press_controller.set_propagation_phase (Gtk.PropagationPhase.CAPTURE);
        plus_press_controller.pressed.connect (() => {
            if (value >= Cinder.Application.settings.temperature_unit.get_maximum_temperature ()) {
                return;
            }
            value++;
            update_temperature_label ();
            value_changed (value);
        });

        var plus_long_press_controller = new Gtk.GestureLongPress ();
        plus_long_press_controller.set_propagation_phase (Gtk.PropagationPhase.CAPTURE);
        plus_long_press_controller.end.connect (() => {
            stop_long_press_updates ();
        });
        plus_long_press_controller.pressed.connect (() => {
            start_long_press_updates (() => {
                if (value >= Cinder.Application.settings.temperature_unit.get_maximum_temperature ()) {
                    return;
                }
                value++;
            });
        });

        plus_button.add_controller (plus_press_controller);
        plus_button.add_controller (plus_long_press_controller);

        temperature_label = new Gtk.Label (null) {
            width_request = 50 // TODO: Find a way to compute this
        };
        temperature_label.add_css_class ("title-4");
        Idle.add (() => {
            update_temperature_label ();
            return false;
        });
        
        // TODO: Bind to settings for temperature unit

        append (minus_button);
        append (temperature_label);
        append (plus_button);
    }

    public void set_target_temperature (int temperature) {
        value = temperature;
        update_temperature_label ();
    }

    private void update_temperature_label () {
        // TODO: Make this aware of temperature unit
        temperature_label.label = "%i°".printf (value);
    }

    private void start_long_press_updates (ValueUpdateFunc value_update_func) {
        long_press_updates_cancellable = new GLib.Cancellable ();
        long_press_updates_thread = new GLib.Thread<void> ("long-press-updates", () => {
            while (!long_press_updates_cancellable.is_cancelled ()) {
                value_update_func ();
                update_temperature_label ();
                Thread.usleep (125000); // 0.125 seconds
            }
        });
    }

    private void stop_long_press_updates () {
        long_press_updates_cancellable.cancel ();
        value_changed (value); // Only emit once the value is done changing
        debug ("New value: %i", value);
    }

    public delegate void ValueUpdateFunc ();

    public signal void value_changed (int value);
    //  public signal void minus_button_clicked ();
    //  public signal void plus_button_clicked ();

}