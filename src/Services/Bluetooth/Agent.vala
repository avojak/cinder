/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

[DBus (name = "org.bluez.Error")]
public errordomain BluezError {
    REJECTED,
    CANCELED
}

[DBus (name = "org.bluez.Agent1")]
public class Cinder.Bluetooth.Agent : Object {
    private const string PATH = "/org/bluez/agent/elementary";
    Gtk.Window? main_window;

    //  private PairDialog pair_dialog;

    [DBus (visible=false)]
    public Agent (Gtk.Window? main_window) {
        this.main_window = main_window;
        Bus.own_name (GLib.BusType.SYSTEM, "org.bluez.AgentManager1", GLib.BusNameOwnerFlags.NONE,
            (connection, name) => {
                try {
                    connection.register_object (PATH, this);
                    ready = true;
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            },
            (connection, name) => {},
            (connection, name) => {}
        );
    }

    [DBus (visible=false)]
    public bool ready { get; private set; }

    [DBus (visible=false)]
    public signal void unregistered ();

    [DBus (visible=false)]
    public GLib.ObjectPath get_path () {
        return new GLib.ObjectPath (PATH);
    }

    public void release () throws GLib.Error {
        unregistered ();
    }

    public async string request_pin_code (GLib.ObjectPath device) throws GLib.Error, BluezError {
        throw new BluezError.REJECTED ("Pairing method not supported");
    }

    // Called to display a pin code on-screen that needs to be entered on the other device. Can return
    // instantly
    public async void display_pin_code (GLib.ObjectPath device, string pincode) throws GLib.Error, BluezError {
        //  pair_dialog = new PairDialog.display_pin_code (device, pincode, main_window);
        //  pair_dialog.present ();
    }

    public async uint32 request_passkey (GLib.ObjectPath device) throws GLib.Error, BluezError {
        throw new BluezError.REJECTED ("Pairing method not supported");
    }

    // Called to display a passkey on-screen that needs to be entered on the other device. Can return
    // instantly
    public async void display_passkey (GLib.ObjectPath device, uint32 passkey, uint16 entered) throws GLib.Error {
        //  pair_dialog = new PairDialog.display_passkey (device, passkey, entered, main_window);
        //  pair_dialog.present ();
    }

    // Called to request confirmation from the user that they want to pair with the given device and that
    // the passkey matches. **MUST** throw BluezError if pairing is to be rejected. This is handled in
    // `check_pairing_response`. If the method returns without an error, pairing is authorized
    public async void request_confirmation (GLib.ObjectPath device, uint32 passkey) throws GLib.Error, BluezError {
        //  pair_dialog = new PairDialog.request_confirmation (device, passkey, main_window);
        //  yield check_pairing_response (pair_dialog);
    }

    // Called to request confirmation from the user that they want to pair with the given device
    // **MUST** throw BluezError if pairing is to be rejected. This is handled in `check_pairing_response`
    // If the method returns without an error, pairing is authorized
    public async void request_authorization (GLib.ObjectPath device) throws GLib.Error, BluezError {
        //  pair_dialog = new PairDialog.request_authorization (device, main_window);
        //  yield check_pairing_response (pair_dialog);
    }

    // Called to authorize the use of a specific service (Audio/HID/etc), so we restrict this to paired
    // devices only
    public void authorize_service (GLib.ObjectPath device_path, string uuid) throws GLib.Error, BluezError {
        var device = get_device_from_object_path (device_path);

        bool paired = device.paired;
        bool trusted = device.trusted;

        // Shouldn't really happen as trusted devices should be automatically authorized, but lets handle it anyway
        if (paired && trusted) {
            // allow
            return;
        }

        // A device that has been paired, but not yet trusted, trust it and allow it to access
        // services
        if (paired && !trusted) {
            device.trusted = true;
            // allow
            return;
        }

        // Reject everything else
        throw new BluezError.REJECTED ("Rejecting service auth, not paired or trusted");
    }

    public void cancel () throws GLib.Error {
        //  if (pair_dialog != null) {
        //      pair_dialog.cancelled = true;
        //      pair_dialog.destroy ();
        //  }
    }

    //  private async void check_pairing_response (PairDialog dialog) throws BluezError {
    //      SourceFunc callback = check_pairing_response.callback;
    //      BluezError? error = null;

    //      dialog.response.connect ((response) => {
    //          if (response != Gtk.ResponseType.ACCEPT || dialog.cancelled) {
    //              if (dialog.cancelled) {
    //                  error = new BluezError.CANCELED ("Pairing cancelled");
    //              } else {
    //                  error = new BluezError.REJECTED ("Pairing rejected");
    //              }
    //          }

    //          Idle.add ((owned)callback);
    //          dialog.destroy ();
    //      });

    //      dialog.present ();

    //      yield;

    //      if (error != null) {
    //          throw error;
    //      }
    //  }

    private Device get_device_from_object_path (ObjectPath object_path) throws GLib.Error {
        return Bus.get_proxy_sync<Device> (BusType.SYSTEM, "org.bluez", object_path, DBusProxyFlags.GET_INVALIDATED_PROPERTIES);
    }
}