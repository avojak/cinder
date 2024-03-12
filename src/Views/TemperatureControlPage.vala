/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.TemperatureControlPage : Gtk.Box {

    private Gtk.Revealer control_revealer;
    private Gtk.Label temperature_label;
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

        units_label = new Gtk.Label (null);
        units_label.add_css_class ("temperature-label");

        var temperature_control = new Cinder.TemperatureControl (Cinder.Application.settings.default_temperature) {
            hexpand = true,
            vexpand = false
        };
        control_revealer = new Gtk.Revealer () {
            child = temperature_control,
            reveal_child = false
        };

        append (temperature_label);
        append (control_revealer);

        //  set_current_temperature (null);
        temperature_label.label = _("Empty");
    }

    public void show_controls () {
        control_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_UP);
        control_revealer.set_reveal_child (true);
    }

    public void hide_controls () {
        control_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
        control_revealer.set_reveal_child (false);
    }

    public void set_current_temperature (int? temperature) {
        temperature_label.label = "%s°".printf (temperature == null ? "-" : temperature.to_string ());
    }

}