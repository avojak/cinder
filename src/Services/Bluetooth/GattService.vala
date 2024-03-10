/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

[DBus (name = "org.bluez.GattService1")]
public interface Cinder.Bluetooth.GattService : GLib.Object {

    public abstract GLib.ObjectPath[] includes { owned get; }
    public abstract bool primary { owned get; }
    public abstract GLib.ObjectPath device { owned get; }
    public abstract string UUID { owned get; }

}