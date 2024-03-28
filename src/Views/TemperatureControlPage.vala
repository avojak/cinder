/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.TemperatureControlPage : Gtk.Box {

    private Cinder.TemperatureControl temperature_control;
    private Gtk.Revealer control_revealer;
    private Gtk.Stack stack;
    private Gtk.Label temperature_label;
    private Gtk.Label empty_label;
    private Gtk.Label units_label;

    public TemperatureControlPage () {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 16,
            hexpand: true,
            vexpand: true
        );
    }

    construct {
        temperature_label = new Gtk.Label (null) {
            hexpand = true,
            vexpand = true
        };
        temperature_label.add_css_class ("temperature-label");

        empty_label = new Gtk.Label (_("Empty")) {
            hexpand = true,
            vexpand = true
        };
        empty_label.add_css_class ("temperature-label");

        stack = new Gtk.Stack () {
            margin_end = 32
        };
        stack.add_named (temperature_label, "temperature");
        stack.add_named (empty_label, "empty");

        //  units_label = new Gtk.Label (null);
        //  units_label.add_css_class ("temperature-label");

        temperature_control = new Cinder.TemperatureControl (Cinder.Application.settings.default_temperature) {
            hexpand = true,
            vexpand = false
        };
        control_revealer = new Gtk.Revealer () {
            child = temperature_control,
            reveal_child = false
        };

        append (stack);
        append (control_revealer);

        //  set_current_temperature (null);
        //  temperature_label.label = _("Empty");
        stack.set_visible_child_name ("empty");
    }

    public void set_current_temperature (int temperature) {
        temperature_label.label = "%i°".printf (temperature);
    }

    public void set_target_temperature (int temperature) {
        temperature_control.set_target_temperature (temperature);
    }

    public void device_empty () {
        stack.set_visible_child_name ("empty");
        control_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
        control_revealer.set_reveal_child (false);
    }

    public void device_not_empty () {
        stack.set_visible_child_name ("temperature");
        control_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_UP);
        control_revealer.set_reveal_child (true);
    }

    //  public void mug_empty () {
    //      hide_controls ();
    //      temperature_label.label = _("Empty");
    //  }

    //  public void mug_not_empty () {
    //      show_controls ();
    //  }

}