/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

[DBus (name = "org.bluez.GattCharacteristic1")]
public interface Cinder.Bluetooth.GattCharacteristic : GLib.Object {
    public abstract uint8[] read_value(HashTable<string, Variant> options) throws GLib.Error;
    public abstract void write_value(uint8[] value, HashTable<string, Variant> options) throws GLib.Error;
    public abstract void start_notify() throws GLib.Error;
    public abstract void stop_notify() throws GLib.Error;

    public abstract uint8[] value { owned get; }
    public abstract string[] flags { owned get; }
    public abstract bool notify_acquired { owned get; }
    public abstract bool notifying { owned get; }
    public abstract bool write_acquired { owned get; }
    public abstract GLib.ObjectPath service { owned get; }
    public abstract string UUID { owned get; }
}