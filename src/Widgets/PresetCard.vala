/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
*/

public class Cinder.PresetCard : Gtk.FlowBoxChild {

    public string title { get; construct; }
    public int temperature { get; construct; }

    public PresetCard (string title, int temperature) {
        Object (
            title: title,
            temperature: temperature
        );
    }

    construct {
        add_css_class ("card");
        add_css_class ("activatable");

        var title_label = new Gtk.Label (title) {
            margin_top = 4,
            margin_start = 8,
            margin_end = 8
        };
        title_label.add_css_class ("title-4");

        Gtk.Label temperature_label;
        if (temperature == 0) {
            temperature_label = new Gtk.Label (title);
        }
        else {
            temperature_label = new Gtk.Label ("%i°".printf (temperature)) {
                margin_bottom = 4,
                margin_start = 8,
                margin_end = 8
            };
        }
        temperature_label.add_css_class ("preset-temperature");

        if (temperature == 0) {
            child = temperature_label;
        } else {
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
            box.append (title_label);
            box.append (temperature_label);
    
            child = box;
        }
    }

}