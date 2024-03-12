/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.TemperatureControl : Gtk.Box {

    public int value { get; set; }

    private Gtk.Label temperature_label;

    public TemperatureControl (int initial_value) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            halign: Gtk.Align.CENTER,
            spacing: 24,
            margin_bottom: 16,
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
        minus_button.clicked.connect (() => {
            value--;
            update_temperature_label ();
            value_changed (value);
        });
        
        var plus_button = new Gtk.Button.from_icon_name ("list-add-symbolic") {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        plus_button.add_css_class ("flat");
        plus_button.add_css_class ("circular");
        plus_button.clicked.connect (() => {
            value++;
            update_temperature_label ();
            value_changed (value);
        });

        temperature_label = new Gtk.Label (null);
        temperature_label.add_css_class ("title-4");
        Idle.add (() => {
            update_temperature_label ();
            return false;
        });
        
        // TODO: Fix things shifting slightly as the label changes

        append (minus_button);
        append (temperature_label);
        append (plus_button);
    }

    private void update_temperature_label () {
        // TODO: Make this aware of temperature unit
        temperature_label.label = "%i°".printf (value);
    }

    public signal void value_changed (int value);
    //  public signal void minus_button_clicked ();
    //  public signal void plus_button_clicked ();

}