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
        var sb = new GLib.StringBuilder ();
        for (int i = bytes.length - 1; i >= 0; i--) {
            sb.append (Cinder.Utils.int_to_hex (bytes[i], 2));
        }
        return Cinder.Utils.hex_to_int (sb.str);
    }

    //  public static uint16 little_endian_bytes_to_uint16 (uint8[] bytes) {
    //      uint16 value = bytes[1];
    //      value = value << 8;
    //      value = value & bytes[0];
    //      return value;
    //  }

    public static string bytes_to_hex (uint8[] bytes) {
        var sb = new GLib.StringBuilder ();
        foreach (var byte in bytes) {
            sb.append (Cinder.Utils.int_to_hex (byte, 2));
        }
        return sb.str;
    }

    public static int celsius_to_fahrenheit (int temp) {
        return (int) Math.round (((double) temp) * (9.0 / 5.0) + 32.0);
    }

    public static int fahrenheit_to_celsius (int temp) {
        return (int) Math.round (((double) (temp - 32)) * (5.0 / 9.0));
    }

    public static uint8[] uint16_to_bytes (uint16 value) {
        //  var hex_string = Cinder.Utils.int_to_hex (value, 4, true);
        uint8[] data = new uint8[2];
        //  data[0] = hex_string[0];
        //  data[1] = hex_string[1];
        //  return data;
        //  return value.to_string ().data;
        //  uint8[] data = new uint8[2];
        data[0] = (uint8) (value & 0x00ff);
        data[1] = (uint8) (value >> 8);
        return data;
    }

}