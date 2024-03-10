/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

[DBus (name = "org.bluez.GattDescriptor1")]
public interface Cinder.Bluetooth.GattDescriptor : GLib.Object {
    public abstract uint8[] read_value(HashTable<string, Variant> options) throws GLib.Error;
    public abstract void write_value(uint8[] value, HashTable<string, Variant> options) throws GLib.Error;

    public abstract uint8[] value { owned get; }
    public abstract GLib.ObjectPath characteristic { owned get; }
    public abstract string UUID { owned get; }
}