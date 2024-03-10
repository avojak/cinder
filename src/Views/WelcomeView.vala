/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.WelcomeView : Adw.Bin {

    private Cinder.DeviceListView device_list_view;    

    construct {
        var header_bar = new Adw.HeaderBar ();

        device_list_view = new Cinder.DeviceListView ();
        device_list_view.device_selected.connect ((device) => {
            //  device_connected (device);
            device_selected (device);
        });

        var clamp = new Adw.Clamp () {
            orientation = Gtk.Orientation.HORIZONTAL,
            maximum_size = 600,
            child = device_list_view
        };

        var status_page = new Adw.StatusPage () {
            title = _("Welcome to %s").printf (APP_NAME),
            description = _("Place your Ember Mug into Pairing Mode and select it below."),
            icon_name = APP_ID,
            child = clamp
        };

        var toolbar_view = new Adw.ToolbarView () {
            content = status_page
        };
        toolbar_view.add_top_bar (header_bar);

        child = toolbar_view;
    }

    public void device_found (Cinder.EmberMug device) {
        device_list_view.add_device (device);
    }

    public void device_removed (Cinder.EmberMug device) {
        device_list_view.remove_device (device);
    }

    public signal void device_selected (Cinder.EmberMug device);

}