/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.Utils : GLib.Object {

    public static string get_mac_address_for_device_path (GLib.ObjectPath device_path) {
        string[] tokens = device_path.split ("/");
        return tokens[tokens.length - 1].replace ("dev_", "").replace ("_", ":");
    }

    public static string int_to_hex (int value, int width = 4, bool prepend_zeros = true) {
        var format_string = "%" + (prepend_zeros ? "0" : "") + width.to_string () + "x";
        return format_string.printf (value);
    }

    public static int hex_to_int (string value) {
        int? result = null;
        string? unparsed = null;
        int.try_parse (value, out result, out unparsed, 16);
        return result;
    }

    public static int little_endian_bytes_to_int (uint8[] bytes) {
        //  var b = new GLib.Bytes (bytes);
        
        var sb = new GLib.StringBuilder ();
        for (int i = bytes.length - 1; i >= 0; i--) {
            sb.append (Cinder.Utils.int_to_hex (bytes[i], 2));
        }
        return Cinder.Utils.hex_to_int (sb.str);
        //  var firmware_version_hex = "%s%s".printf (Cinder.Utils.int_to_hex (firmware_version_bytes[1], 2), Cinder.Utils.int_to_hex (firmware_version_bytes[0], 2));
        //  var firmware_version = Cinder.Utils.hex_to_int (firmware_version_hex);
    }

    public static string bytes_to_hex (uint8[] bytes) {
        var sb = new GLib.StringBuilder ();
        foreach (var byte in bytes) {
            sb.append (Cinder.Utils.int_to_hex (byte, 2));
        }
        return sb.str;
    }

}