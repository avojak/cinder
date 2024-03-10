/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.EmberDeviceRow : Adw.ActionRow {

    //  private enum Status {
    //      UNPAIRED,
    //      PAIRING,
    //      CONNECTED,
    //      CONNECTING,
    //      DISCONNECTING,
    //      NOT_CONNECTED,
    //      UNABLE_TO_CONNECT,
    //      UNABLE_TO_CONNECT_PAIRED;

    //      public string to_string () {
    //          switch (this) {
    //              case UNPAIRED:
    //                  return _("Available");
    //              case PAIRING:
    //                  return _("Pairing…");
    //              case CONNECTED:
    //                  return _("Connected");
    //              case CONNECTING:
    //                  return _("Connecting…");
    //              case DISCONNECTING:
    //                  return _("Disconnecting…");
    //              case UNABLE_TO_CONNECT:
    //              case UNABLE_TO_CONNECT_PAIRED:
    //                  return _("Unable to Connect");
    //              default:
    //                  return _("Not Connected");
    //          }
    //      }
    //  }

    public Cinder.EmberMug? device { get; construct; }

    private Gtk.Label suffix_label;

    public EmberDeviceRow.for_device (Cinder.EmberMug device) {
        Object (
            device: device,
            title: device.device.alias,
            title_lines: 1,
            activatable: true
        );
    }

    construct {
        //  ((DBusProxy)device).g_properties_changed.connect ((changed, invalid) => {
        //      var paired = changed.lookup_value ("Paired", new VariantType ("b"));
        //      if (paired != null) {
        //          compute_status ();
        //          device.connect.begin (); // connect after paired
        //          this.changed ();
        //      }

        //      var connected = changed.lookup_value ("Connected", new VariantType ("b"));
        //      if (connected != null) {
        //          compute_status ();
        //          this.changed ();
        //      }

        //      var name = changed.lookup_value ("Name", new VariantType ("s"));
        //      if (name != null) {
        //          title = device.name;
        //      }
        //  });

        add_prefix (new Gtk.Image.from_icon_name ("cafe-symbolic"));
        suffix_label = new Gtk.Label (null);
        suffix_label.add_css_class ("dim-label");
        add_suffix (suffix_label);

        suffix_label.label = device.status.to_string ();
        device.bind_property ("status", suffix_label, "label", GLib.BindingFlags.DEFAULT, (binding, src_val, ref target_val) => {
            Cinder.EmberMug.Status status = (Cinder.EmberMug.Status) src_val.get_enum ();
            target_val.set_string (status.to_string ());
            return true;
        });
        //  compute_status ();
    }

    //  private void compute_status () {
    //      if (!device.paired) {
    //          suffix_label.label = Status.UNPAIRED.to_string ();
    //      } else if (device.connected) {
    //          suffix_label.label = Status.CONNECTED.to_string ();
    //      } else {
    //          suffix_label.label = Status.NOT_CONNECTED.to_string ();
    //      }
    //  }

    //  private async void row_clicked () {
    //      if (!device.paired) {
    //          attempt_pairing.begin ((obj, res) => {
    //              if (attempt_pairing.end (res)) {
    //                  attempt_connection ();
    //              }
    //          });
    //      } else if (!device.connected) {
    //          attempt_connection ();
    //      //  } else {
    //      //      suffix_label.label = Status.DISCONNECTING.to_string ();
    //      //      try {
    //      //          yield device.disconnect ();
    //      //      } catch (GLib.Error e) {
    //      //          critical (e.message);
    //      //      }
    //      }
    //  }

    //  private async bool attempt_pairing () {
    //      suffix_label.label = Status.PAIRING.to_string ();
    //      try {
    //          yield device.pair ();
    //      } catch (GLib.Error e) {
    //          suffix_label.label = Status.UNABLE_TO_CONNECT.to_string ();
    //          critical (e.message);
    //          return false;
    //      }
    //      return true;
    //  }

    //  private void attempt_connection () {
    //      suffix_label.label = Status.CONNECTING.to_string ();
    //      device.connect.begin ((obj, res) => {
    //          try {
    //              device.connect.end (res);
    //              device_connected ();
    //          } catch (GLib.Error e) {
    //              suffix_label.label = Status.UNABLE_TO_CONNECT_PAIRED.to_string ();
    //              critical (e.message);
    //          }
    //      });
    //  }

    //  public signal void device_connected ();

}