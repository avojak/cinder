/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.DeviceListView : Adw.Bin {

    private Adw.PreferencesGroup devices_group;
    private Gee.Map<Cinder.EmberMug, Cinder.EmberDeviceRow> device_rows;
    private Gtk.Widget placeholder_row;

    construct {
        device_rows = new Gee.HashMap<Cinder.EmberMug, Cinder.EmberDeviceRow> ();

        var spinner = new Gtk.Spinner ();
        spinner.start ();
        devices_group = new Adw.PreferencesGroup () {
            title = _("Ember Devices"),
            header_suffix = spinner
        };

        placeholder_row = new Gtk.Label (_("No Ember devices found"));
        placeholder_row.add_css_class ("dim-label");
        devices_group.add (placeholder_row);

        child = devices_group;
    }

    public void add_device (Cinder.EmberMug device) {
        var row = new Cinder.EmberDeviceRow.for_device (device);
        row.activated.connect (() => {
            device_selected (device);
        });
        device_rows.set (device, row);
        if (device_rows.size == 1) {
            devices_group.remove (placeholder_row);
        }
        devices_group.add (row);
    }

    public void remove_device (Cinder.EmberMug device) {
        Cinder.EmberDeviceRow row;
        device_rows.unset (device, out row);
        if (device_rows.size == 0) {
            devices_group.add (placeholder_row);
        }
        devices_group.remove (row);
    }

    public signal void device_selected (Cinder.EmberMug device);

    //  public signal void device_connected (Cinder.EmberMug device);

}