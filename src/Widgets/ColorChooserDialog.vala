/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.ColorChooserDialog : Adw.Window {

    public Gdk.RGBA initial_value { get; construct; }

    private Cinder.HsvColorChooser color_chooser;

    public ColorChooserDialog (Gtk.Window parent, Gdk.RGBA initial_value) {
        Object (
            transient_for: parent,
            modal: true,
            deletable: false,
            initial_value: initial_value
        );
    }

    construct {
        var header_bar = new Adw.HeaderBar () {
            title_widget = new Adw.WindowTitle (_("Pick a Color"), "")
        };

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));
        var select_button = new Gtk.Button.with_label (_("Select"));
        select_button.add_css_class ("suggested-action");

        cancel_button.clicked.connect (() => {
            close ();
        });
        select_button.clicked.connect (() => {
            color_selected (color_chooser.get_value ());
        });

        header_bar.pack_start (cancel_button);
        header_bar.pack_end (select_button);

        var preview_tile = new Gtk.DrawingArea () {
            hexpand = true,
            vexpand = true
        };
        preview_tile.set_draw_func ((drawing_area, cr, width, height) => {
            int x, y, w, h;
            drawing_area.get_bounds (out x, out y, out w, out h);
            var color = color_chooser.get_value ();
            debug ("Drawing with color: %s", color.to_string ());
            cr.set_source_rgb (color.red, color.green, color.blue);
            cr.rectangle (x, y, width, height);
            cr.fill ();
        });

        var preview_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 16) {
            overflow = Gtk.Overflow.HIDDEN
        };
        preview_box.add_css_class ("card");
        preview_box.append (preview_tile);

        var preview_clamp_h = new Adw.Clamp () {
            orientation = Gtk.Orientation.HORIZONTAL,
            maximum_size = 100,
            child = preview_box
        };

        var preview_clamp_v = new Adw.Clamp () {
            orientation = Gtk.Orientation.VERTICAL,
            maximum_size = 50,
            child = preview_clamp_h
        };

        color_chooser = new Cinder.HsvColorChooser (initial_value);
        color_chooser.value_changed.connect (() => {
            preview_tile.queue_draw ();
        });

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 16);
        box.append (preview_clamp_v);
        box.append (color_chooser);

        var clamp = new Adw.Clamp () {
            orientation = Gtk.Orientation.HORIZONTAL,
            maximum_size = 200,
            child = box
        };

        var toolbar_view = new Adw.ToolbarView () {
            content = clamp
        };
        toolbar_view.add_top_bar (header_bar);

        content = toolbar_view;

        var escape_key_controller = new Gtk.EventControllerKey ();
        escape_key_controller.key_pressed.connect ((keyval, keycode, state) => {
            if (keyval == Gdk.Key.Escape) {
                close ();
            }
        });
        toolbar_view.add_controller (escape_key_controller);
    }

    public signal void color_selected (Gdk.RGBA color);

}