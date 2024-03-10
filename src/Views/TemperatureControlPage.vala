/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.TemperatureControlPage : Adw.Bin {

    private Gtk.Label temperature_label;
    private Gtk.Label units_label;

    public TemperatureControlPage () {
        Object (
            hexpand: true,
            vexpand: true
        );
    }

    construct {
        temperature_label = new Gtk.Label (null);
        temperature_label.add_css_class ("temperature-label");

        units_label = new Gtk.Label (null);
        units_label.add_css_class ("temperature-label");

        child = temperature_label;

        set_temperature (null);
    }

    public void set_temperature (int? temperature) {
        temperature_label.label = "%s°".printf (temperature == null ? "-" : temperature.to_string ());
    }

}