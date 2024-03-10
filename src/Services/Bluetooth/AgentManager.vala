/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

[DBus (name = "org.bluez.AgentManager1")]
public interface Cinder.Bluetooth.AgentManager : GLib.Object {

    public abstract void register_agent (GLib.ObjectPath agent, string capability) throws GLib.Error;
    public abstract void request_default_agent (GLib.ObjectPath agent) throws GLib.Error;
    public abstract void unregister_agent (GLib.ObjectPath agent) throws GLib.Error;

}