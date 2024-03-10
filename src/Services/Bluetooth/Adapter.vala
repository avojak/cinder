/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

[DBus (name = "org.bluez.Adapter1")]
public interface Cinder.Bluetooth.Adapter : GLib.Object {
    public abstract void remove_device (GLib.ObjectPath device) throws GLib.Error;
    public abstract void set_discovery_filter (GLib.HashTable<string, GLib.Variant> properties) throws GLib.Error;
    public abstract async void start_discovery () throws GLib.Error;
    public abstract async void stop_discovery () throws GLib.Error;

    public abstract string[] UUIDs { owned get; }
    public abstract bool discoverable { get; set; }
    public abstract bool discovering { get; }
    public abstract bool pairable { get; set; }
    public abstract bool powered { get; set; }
    public abstract string address { owned get; }
    public abstract string alias { owned get; set; }
    public abstract string modalias { owned get; }
    public abstract string name { owned get; }
    public abstract uint @class { get; }
    public abstract uint discoverable_timeout { get; }
    public abstract uint pairable_timeout { get; }
}