/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

[DBus (name = "org.bluez.AdvertisementMonitor1")]
public interface Cinder.Bluetooth.AdvertisementMonitor : GLib.Object {

    public abstract void device_found (GLib.ObjectPath device) throws GLib.Error;
    public abstract void device_lost (GLib.ObjectPath device) throws GLib.Error;

    public abstract signal void release ();
    public abstract signal void activate ();

}