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
        var flow_box = new Gtk.FlowBox ();

        child = flow_box;
    }

}