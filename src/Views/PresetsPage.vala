/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.PresetsPage : Adw.Bin {

    public PresetsPage () {
        Object (
            hexpand: true,
            vexpand: true
        );
    }

    construct {
        var flow_box = new Gtk.FlowBox () {
            orientation = Gtk.Orientation.HORIZONTAL,
            valign = Gtk.Align.START,
            activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.NONE,
            homogeneous = true,
            column_spacing = 8,
            row_spacing = 8,
            margin_start = 16,
            margin_end = 16,
            margin_top = 16,
            margin_bottom = 16,
            hexpand = true,
            vexpand = false
        };
        flow_box.child_activated.connect ((child) => {
            preset_selected (((Cinder.PresetCard) child).temperature);
        });

        var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic") {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        add_button.add_css_class ("circular");
        add_button.add_css_class ("image-button");

        //  var off_label = new Gtk.Label (_("Off")) {
        //      margin_bottom = 4,
        //      margin_start = 8,
        //      margin_end = 8
        //  };
        //  off_label.add_css_class ("preset-temperature");
        //  var off_preset = new Gtk.FlowBoxChild () {
        //      child = off_label
        //  };
        //  off_preset.add_css_class ("card");
        //  off_preset.add_css_class ("activatable");

        //  var off_preset = ;

        flow_box.append (new Cinder.PresetCard (_("Off"), 0));
        foreach (var entry in parse_temperature_presets ().entries) {
            flow_box.append (new Cinder.PresetCard (entry.key, entry.value));
        }
        flow_box.append (add_button);

        var scrolled_window = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.AUTOMATIC,
            vscrollbar_policy = Gtk.PolicyType.AUTOMATIC,
            child = flow_box
        };

        child = scrolled_window;

        add_button.clicked.connect (() => {
            // TODO
        });
    }

    private Gee.Map<string, int> parse_temperature_presets () {
        Gee.Map<string, int> presets = new Gee.HashMap<string, int> ();
        var value = Cinder.Application.settings.temperature_presets;
        var preset_strings = value.split (",");
        foreach (var preset_string in preset_strings) {
            var tokens = preset_string.split (":");
            presets.set (tokens[0], int.parse (tokens[1]));
        }
        return presets;
    }

    private void save_temperature_presets (Gee.Map<string, int> presets) {
        var sb = new GLib.StringBuilder ();
        foreach (var entry in presets.entries) {
            sb.append_printf ("%s:%i,", entry.key, entry.value);
        }
        Cinder.Application.settings.temperature_presets = sb.str.substring (0, sb.str.length);
    }

    public signal void preset_selected (int temperature);

}