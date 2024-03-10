/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

[DBus (name = "org.bluez.Device1")]
public interface Cinder.Bluetooth.Device : Object {
    public abstract void cancel_pairing () throws GLib.Error;
    public abstract async void connect () throws GLib.Error;
    public abstract void connect_profile (string UUID) throws GLib.Error; //vala-lint=naming-convention
    public abstract async void disconnect () throws GLib.Error;
    public abstract void disconnect_profile (string UUID) throws GLib.Error; //vala-lint=naming-convention
    public abstract async void pair () throws GLib.Error;

    public abstract string[] UUIDs { owned get; }
    public abstract bool blocked { owned get; set; }
    public abstract bool connected { owned get; }
    public abstract bool legacy_pairing { owned get; }
    public abstract bool paired { owned get; }
    public abstract bool trusted { owned get; set; }
    public abstract int16 RSSI { owned get; }
    public abstract GLib.ObjectPath adapter { owned get; }
    public abstract string address { owned get; }
    public abstract string alias { owned get; set; }
    public abstract string icon { owned get; }
    public abstract string modalias { owned get; }
    public abstract string name { owned get; }
    public abstract uint16 appearance { owned get; }
    public abstract uint32 @class { owned get; }
    public abstract GLib.HashTable<uint16, GLib.Variant> manufacturer_data { owned get; }
    public abstract GLib.HashTable<uint8, GLib.Variant> advertising_data { owned get; }
}