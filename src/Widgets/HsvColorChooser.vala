/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.HsvColorChooser : Adw.Bin {

    public Gdk.RGBA initial_value { get; construct; }

    private Gtk.Scale scale;

    public HsvColorChooser (Gdk.RGBA initial_value) {
        Object (
            initial_value: initial_value
        );
    }

    construct {
        float h, s, v;
        Gtk.rgb_to_hsv (initial_value.red, initial_value.green, initial_value.blue, out h, out s, out v);

        scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 100, 0.1);
        scale.set_value (h * 100.0);
        scale.add_css_class ("hsv-scale");
        scale.value_changed.connect (() => {
            debug ("Value changed: %s", get_value ().to_string ());
            value_changed (get_value ());
        });
        child = scale;
    }

    public Gdk.RGBA get_value () {
        float r, g, b;
        Gtk.hsv_to_rgb ((float) (scale.get_value () / 100.0), 1, 1, out r, out g, out b);
        return Gdk.RGBA () {
            red = r,
            green = g,
            blue = b,
            alpha = 1.0f
        };
    }

    public signal void value_changed (Gdk.RGBA value);

}