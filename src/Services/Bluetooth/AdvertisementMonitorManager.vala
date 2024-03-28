/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

[DBus (name = "org.bluez.AdvertisementMonitorManager1")]
public interface Cinder.Bluetooth.AdvertisementMonitorManager : GLib.Object {

    public abstract void register_monitor (GLib.ObjectPath application) throws GLib.Error;
    public abstract void unregister_monitor (GLib.ObjectPath application) throws GLib.Error;

}