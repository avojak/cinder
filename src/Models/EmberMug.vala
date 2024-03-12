/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.EmberMug : GLib.Object {

    //  struct Command {
    //      public Characteristic characteristic;
    //      public Action action;
    //  }

    public enum Characteristic {
        MUG_NAME = 1, // 0x0001
        CURRENT_TEMPERATURE = 2, // 0x0002
        TARGET_TEMPERATURE = 3, // 0x0003
        TEMPERATURE_UNIT = 4, // 0x0004
        LIQUID_LEVEL = 5, // 0x0005
        DATE_TIME_ZONE = 6, // 0x0006
        BATTERY = 7, // 0x0007
        LIQUID_STATE = 8, // 0x0008
        VOLUME = 9, // 0x0009
        LAST_LOCATION = 10, // 0x000a
        UUID_ACCELERATION = 11, // 0x000b
        FIRMWARE = 12, // 0x000c
        MUG_ID = 13, // 0x000d
        DSK = 14, // 0x000e
        UDSK = 15, // 0x000f
        CONTROL_REGISTER_ADDRESS = 16, // 0x0010
        CONTROL_REGISTER_DATA = 17, // 0x0011
        PUSH_EVENTS = 18, // 0x0012
        STATISTICS = 19, // 0x0013
        LED_COLOR = 20; // 0x0014

        public static Characteristic from_uuid (string uuid) {
            var tokens = uuid.split ("-");
            var hex_string = tokens[0].substring (4);
            return Cinder.Utils.hex_to_int (hex_string);
        }

        public string to_uuid () {
            return EMBER_UUID_FORMAT.printf (Cinder.Utils.int_to_hex (this));
        }

        public bool supports_action (Cinder.EmberMug.Action action) {
            switch (this) {
                case MUG_NAME:
                    return (action == READ || action == WRITE);
                case CURRENT_TEMPERATURE:
                    return action == READ;
                case TARGET_TEMPERATURE:
                    return (action == READ || action == WRITE);
                case TEMPERATURE_UNIT:
                    return (action == READ || action == WRITE);
                case LIQUID_LEVEL:
                    return action == READ;
                case DATE_TIME_ZONE:
                    return action == WRITE;
                case BATTERY:
                    return action == READ;
                case LIQUID_STATE:
                    return action == READ;
                case FIRMWARE:
                    return action == READ;
                case PUSH_EVENTS:
                    return action == READ || action == NOTIFICATION;
                case LED_COLOR:
                    return (action == READ || action == WRITE);
                default:
                    return false;
            }
        }

        public string to_string () {
            switch (this) {
                case MUG_NAME:
                    return "Mug Name";
                case CURRENT_TEMPERATURE:
                    return "Current Temperature";
                case TARGET_TEMPERATURE:
                    return "Target Temperature";
                case TEMPERATURE_UNIT:
                    return "Temperature Unit";
                case LIQUID_LEVEL:
                    return "Liquid Level";
                case DATE_TIME_ZONE:
                    return "Date Time Zone";
                case BATTERY:
                    return "Battery";
                case LIQUID_STATE:
                    return "Liquid State";
                case VOLUME:
                    return "Volume";
                case LAST_LOCATION:
                    return "Last Location";
                case UUID_ACCELERATION:
                    return "UUID Acceleration";
                case FIRMWARE:
                    return "Firmware";
                case MUG_ID:
                    return "Mug ID";
                case DSK:
                    return "DSK";
                case UDSK:
                    return "UDSK";
                case CONTROL_REGISTER_ADDRESS:
                    return "Control Register Address";
                case CONTROL_REGISTER_DATA:
                    return "Control Register Data";
                case PUSH_EVENTS:
                    return "Push Events";
                case STATISTICS:
                    return "Statistics";
                case LED_COLOR:
                    return "LED Color";
                default:
                    assert_not_reached ();
            }
        }
    }

    public enum Action {
        READ,
        WRITE,
        NOTIFICATION;
    }

    public enum Service {
        STANDARD = 13858,
        TRAVEL_MUG = 13857,
        TRAVEL_MUG_OTHER = 8609;

        public string to_uuid () {
            return EMBER_UUID_FORMAT.printf (Cinder.Utils.int_to_hex (this));
        }

        public static Service[] all () {
            return {
                STANDARD, TRAVEL_MUG, TRAVEL_MUG_OTHER
            };
        }

        public static Gee.List<string> get_all_uuids () {
            Gee.List<string> uuids = new Gee.ArrayList<string> ();
            foreach (var service in all ()) {
                uuids.add (service.to_uuid ());
            }
            return uuids;
        }
    }

    public enum Status {
        UNPAIRED,
        PAIRING,
        CONNECTED,
        CONNECTING,
        DISCONNECTING,
        NOT_CONNECTED,
        UNABLE_TO_CONNECT,
        UNABLE_TO_CONNECT_PAIRED;

        public string to_string () {
            switch (this) {
                case UNPAIRED:
                    return _("Available");
                case PAIRING:
                    return _("Pairing…");
                case CONNECTED:
                    return _("Connected");
                case CONNECTING:
                    return _("Connecting…");
                case DISCONNECTING:
                    return _("Disconnecting…");
                case UNABLE_TO_CONNECT:
                case UNABLE_TO_CONNECT_PAIRED:
                    return _("Unable to Connect");
                default:
                    return _("Not Connected");
            }
        }
    }

    public enum LiquidState {
        EMPTY = 1,
        FILLING = 2,
        COOLING = 4,
        HEATING = 5,
        STABLE_TEMPERATURE = 6;

        public string to_string () {
            switch (this) {
                case EMPTY:
                    return _("Empty");
                case FILLING:
                    return _("Filling…");
                case COOLING:
                    return _("Cooling…");
                case HEATING:
                    return _("Heating…");
                case STABLE_TEMPERATURE:
                    return _("Target temperature reached");
                default:
                    return _("Unknown");
            }
        }
    }

    public enum LiquidLevel {
        EMPTY = 0,
        NOT_EMPTY = 30;

        public string to_string () {
            switch (this) {
                case EMPTY:
                    return _("Empty");
                case NOT_EMPTY:
                    return _("Not empty");
                default:
                    assert_not_reached ();
            }
        }
    }

    public enum TemperatureUnit {

        CELSIUS = 0,
        FAHRENHEIT = 1;

        public string to_string () {
            switch (this) {
                case CELSIUS:
                    return _("Celsius");
                case FAHRENHEIT:
                    return _("Fahrenheit");
                default:
                    assert_not_reached ();
            }
        }

    }

    public enum PushEvent {

        REFRESH_BATTERY_LEVEL = 1,
        CHARGING = 2,
        NOT_CHARGING = 3,
        REFRESH_TARGET_TEMPERATURE = 4,
        REFRESH_CURRENT_TEMPERATURE = 5,
        REFRESH_LIQUID_LEVEL = 7,
        REFRESH_LIQUID_STATE = 8;

        public string to_string () {
            switch (this) {
                case REFRESH_BATTERY_LEVEL:
                    return _("Refresh battery level");
                case CHARGING:
                    return _("Charging");
                case NOT_CHARGING:
                    return _("Not charging");
                case REFRESH_TARGET_TEMPERATURE:
                    return _("Refresh target temperature");
                case REFRESH_CURRENT_TEMPERATURE:
                    return _("Refresh current temperature");
                case REFRESH_LIQUID_LEVEL:
                    return _("Refresh liquid level");
                case REFRESH_LIQUID_STATE:
                    return _("Refresh liquid state");
                default:
                    return _("Not implemented");
            }
        }
    }

    public class BatteryStatus : GLib.Object {

        public int? percent_charged { get; set; }
        public bool? charging { get; set; }

    }

    public class FirmwareInfo : GLib.Object {

        public int? firmware_version { get; set; }
        public int? hardware_version { get; set; }
        public int? bootloader_version { get; set; }

    }

    public unowned Cinder.Bluetooth.Device device { get; construct; }

    private bool _connected = false;
    public bool connected {
        get { return _connected; }
        set {
            _connected = value;
            compute_status ();
            debug ("%s connected = %s", device.alias, connected.to_string ());
        }
    }

    private bool _paired = false;
    public bool paired { 
        get { return _paired; }
        set {
            _paired = value;
            compute_status ();
            debug ("%s paired = %s", device.alias, paired.to_string ());
        }
    }

    public Status status { get; private set; default = Status.UNPAIRED; }

    public Cinder.EmberMug.BatteryStatus battery_status { get; private set; default = new Cinder.EmberMug.BatteryStatus(); }
    public int? current_temperature { get; private set; }
    public int? target_temperature { get; private set; }
    public Cinder.EmberMug.TemperatureUnit? temperature_unit { get; private set; }
    public Cinder.EmberMug.LiquidLevel? liquid_level { get; private set; }
    public Cinder.EmberMug.LiquidState? liquid_state { get; private set; }
    public Gdk.RGBA led_color { get; private set; default = Gdk.RGBA (); }
    public string? mug_name { get; private set; }
    public Cinder.EmberMug.FirmwareInfo firmware_info { get; private set; default = new Cinder.EmberMug.FirmwareInfo (); }

    private Gee.Map<string, Cinder.Bluetooth.GattService> services;
    private Gee.Map<string, Cinder.Bluetooth.GattCharacteristic> characteristics;

    public EmberMug.for_device (Cinder.Bluetooth.Device device) {
        Object (
            device: device
        );
    }

    construct {
        services = new Gee.HashMap<string, Cinder.Bluetooth.GattService> ();
        characteristics = new Gee.HashMap<string, Cinder.Bluetooth.GattCharacteristic> ();
        //  command_queue = new Gee.ArrayQueue<Cinder.EmberMug.Command?> ();

        //  ((DBusProxy) device).g_properties_changed.connect ((changed, invalid) => {
        //      var connected = changed.lookup_value ("Connected", GLib.VariantType.BOOLEAN);
        //      if (connected != null) {
        //          debug ("%s [address = %s] connected = %s".printf (device.alias, device.address, device.connected.to_string ()));
        //          //  check_global_state ();
        //          if (device.connected) {
        //              device_connected (device);
        //          } else {
        //              device_disconnected (device);
        //          }
        //      }

        //      var paired = changed.lookup_value ("Paired", GLib.VariantType.BOOLEAN);
        //      if (paired != null) {
        //          debug ("%s [address = %s] paired = %s".printf (device.alias, device.address, device.paired.to_string ()));
        //          //  check_global_state ();
        //      }
        //  });
    }

    public void register_service (Cinder.Bluetooth.GattService service) {
        services.set (service.UUID, service);
        debug ("Registered service %s to %s (%s)", service.UUID, device.alias, device.address);
    }

    public bool has_service (string uuid) {
        return services.has_key (uuid);
    }

    public bool supports_characteristic (Cinder.Bluetooth.GattCharacteristic characteristic) {
        foreach (var service in services.values) {
            if (characteristic_belongs_to_service (characteristic as GLib.DBusInterface, service as GLib.DBusInterface)) {
                return true;
            }
        }
        return false;
    }

    public void register_characteristic (Cinder.Bluetooth.GattCharacteristic characteristic) {
        //  lock (characteristics) {
        characteristics.set (characteristic.UUID, characteristic);
        //  }
        var ember_characteristic = Cinder.EmberMug.Characteristic.from_uuid (characteristic.UUID);
        debug ("Registered characteristic %s (%s) to %s (%s)", ember_characteristic.to_string (), characteristic.UUID, device.alias, device.address);
        characteristic_ready (ember_characteristic);
    }

    public async bool attempt_pair () {
        if (paired) {
            debug ("Device already paired");
            return false;
        }
        try {
            status = Status.PAIRING;
            yield device.pair ();
        } catch (GLib.Error e) {
            status = Status.UNABLE_TO_CONNECT;
            critical (e.message);
            return false;
        }
        device.trusted = true;
        return true;
    }

    public async bool attempt_connect () {
        if (!paired) {
            warning ("Cannot connect to unpaired device");
            return false;
        }
        if (connected) {
            debug ("Device already connected");
            return false;
        }
        try {
            status = Status.CONNECTING;
            yield device.connect ();
        } catch (GLib.Error e) {
            status = Status.UNABLE_TO_CONNECT_PAIRED;
            critical (e.message);
            return false;
        }
        return true;
    }

    public void read_mug_name () {
        Cinder.Bluetooth.GattCharacteristic? characteristic = lookup_characteristic (Cinder.EmberMug.Characteristic.MUG_NAME);
        if (characteristic == null) {
            return;
        }
        read_async.begin (characteristic, (obj, res) => {
            var result = read_async.end (res);
            var name = ((string) result).substring (0, result.length);
            debug ("Mug name = %s", name);
            mug_name = name;
            mug_name_changed (name);
        });
    }

    public void write_mug_name (string name) {
        // TODO
    }

    public void read_current_temperature () {
        Cinder.Bluetooth.GattCharacteristic? characteristic = lookup_characteristic (Cinder.EmberMug.Characteristic.CURRENT_TEMPERATURE);
        if (characteristic == null) {
            return;
        }
        read_async.begin (characteristic, (obj, res) => {
            var result = read_async.end (res);
            var value = (int) GLib.Math.round (Cinder.Utils.little_endian_bytes_to_int (result) * 0.01);
            debug ("Current temperature = %i", value);
            current_temperature = value;
            current_temperature_changed (value);
        });
    }

    public void read_target_temperature () {
        Cinder.Bluetooth.GattCharacteristic? characteristic = lookup_characteristic (Cinder.EmberMug.Characteristic.TARGET_TEMPERATURE);
        if (characteristic == null) {
            return;
        }
        read_async.begin (characteristic, (obj, res) => {
            var result = read_async.end (res);
            var value = (int) GLib.Math.round (Cinder.Utils.little_endian_bytes_to_int (result) * 0.01);
            debug ("Target temperature = %i", value);
            target_temperature = value;
            target_temperature_changed (value);
        });
    }

    public void write_target_temperature () {
        // TODO
    }

    public void read_temperature_unit () {
        Cinder.Bluetooth.GattCharacteristic? characteristic = lookup_characteristic (Cinder.EmberMug.Characteristic.TEMPERATURE_UNIT);
        if (characteristic == null) {
            return;
        }
        read_async.begin (characteristic, (obj, res) => {
            var result = read_async.end (res);
            Cinder.EmberMug.TemperatureUnit unit = (Cinder.EmberMug.TemperatureUnit) result[0];
            debug ("Temperature unit = %s", unit.to_string ());
            temperature_unit = unit;
            temperature_unit_changed (unit);
        });
    }

    public void write_temperature_unit () {
        // TODO
    }

    public void read_liquid_level () {
        Cinder.Bluetooth.GattCharacteristic? characteristic = lookup_characteristic (Cinder.EmberMug.Characteristic.LIQUID_LEVEL);
        if (characteristic == null) {
            return;
        }
        read_async.begin (characteristic, (obj, res) => {
            var result = read_async.end (res);
            Cinder.EmberMug.LiquidLevel level = (Cinder.EmberMug.LiquidLevel) result[0];
            debug ("Liquid level = %s", level.to_string ());
            liquid_level = level;
            liquid_level_changed (level);
        });
    }

    public void write_date_time_zone () {
        // TODO
    }

    public void read_battery_status () {
        Cinder.Bluetooth.GattCharacteristic? characteristic = lookup_characteristic (Cinder.EmberMug.Characteristic.BATTERY);
        if (characteristic == null) {
            return;
        }
        read_async.begin (characteristic, (obj, res) => {
            var result = read_async.end (res);
            var percentage = result[0];
            var charging_status = result[1];
            debug ("Battery percentage = %i, Charging status = %i", percentage, charging_status);
            battery_status.percent_charged = percentage;
            battery_status.charging = (charging_status == 1);
            battery_status_changed (battery_status);
        });
    }

    public void read_liquid_state () {
        Cinder.Bluetooth.GattCharacteristic? characteristic = lookup_characteristic (Cinder.EmberMug.Characteristic.LIQUID_STATE);
        if (characteristic == null) {
            return;
        }
        read_async.begin (characteristic, (obj, res) => {
            var result = read_async.end (res);
            Cinder.EmberMug.LiquidState state = (Cinder.EmberMug.LiquidState) result[0];
            if (state == 3) {
                // State 3 is unknown, and should not be handled
                debug ("Unknown liquid state");
                return;
            }
            debug ("Liquid state = %s", state.to_string ());
            liquid_state = state;
            liquid_state_changed (state);
        });
    }

    public void read_firmware_info () {
        Cinder.Bluetooth.GattCharacteristic? characteristic = lookup_characteristic (Cinder.EmberMug.Characteristic.FIRMWARE);
        if (characteristic == null) {
            return;
        }
        read_async.begin (characteristic, (obj, res) => {
            var result = read_async.end (res);

            firmware_info.firmware_version = Cinder.Utils.little_endian_bytes_to_int (result[0:2]);
            firmware_info.hardware_version = Cinder.Utils.little_endian_bytes_to_int (result[2:4]);

            // Bootloader version is optional, and occupies bytes 5-6
            int? bootloader_version = null;
            if (result.length == 6) {
                bootloader_version = Cinder.Utils.little_endian_bytes_to_int (result[4:6]);
                firmware_info.bootloader_version = bootloader_version;
            }

            debug ("Firmware = %i, hardware = %i, bootloader = %s", 
                    firmware_info.firmware_version,
                    firmware_info.hardware_version,
                    firmware_info.bootloader_version == null ? "Not provided" : firmware_info.bootloader_version.to_string ());

            firmware_info_changed (firmware_info);
        });
    }

    public void read_mug_id () {
        // TODO
    }

    public void read_led_color () {
        Cinder.Bluetooth.GattCharacteristic? characteristic = lookup_characteristic (Cinder.EmberMug.Characteristic.LED_COLOR);
        if (characteristic == null) {
            return;
        }
        read_async.begin (characteristic, (obj, res) => {
            var result = read_async.end (res);
            var color_hex_string = "#%s".printf (Cinder.Utils.bytes_to_hex (result));
            if (!led_color.parse (color_hex_string)) {
                warning ("Failed to parse LED color: %s", color_hex_string);
            }
            debug ("LED color = %s", color_hex_string);
            led_color_changed (led_color);
        });
    }

    public void start_push_notifications () {
        try {
            debug ("Starting push notifications");
            var characteristic = lookup_characteristic (Cinder.EmberMug.Characteristic.PUSH_EVENTS);
            characteristic.start_notify ();
            ((DBusProxy) characteristic).g_properties_changed.connect ((changed, invalid) => {
                var value = changed.lookup_value ("Value", GLib.VariantType.BYTESTRING);
                if (value != null) {
                    var push_event = (Cinder.EmberMug.PushEvent) characteristic.value[0];
                    debug ("Received push event: %s", push_event.to_string ());
                    on_push_event_received (push_event);
                }
            });
        } catch (GLib.Error e) {
            warning (e.message);
        }
    }

    public void start_statistics_notifications () {
        try {
            debug ("Starting statistics notifications");
            var characteristic = lookup_characteristic (Cinder.EmberMug.Characteristic.STATISTICS);
            characteristic.start_notify ();
            ((DBusProxy) characteristic).g_properties_changed.connect ((changed, invalid) => {
                var value = changed.lookup_value ("Value", GLib.VariantType.BYTESTRING);
                if (value != null) {
                    var statistics_notification = characteristic.value[0];
                    debug ("Received statistics notification: %i", statistics_notification);
                    debug (Cinder.Utils.bytes_to_hex (characteristic.value));
                    //  on_push_event_received (push_event);
                }
            });
        } catch (GLib.Error e) {
            warning (e.message);
        }
    }

    private void on_push_event_received (Cinder.EmberMug.PushEvent event) {
        switch (event) {
            case Cinder.EmberMug.PushEvent.REFRESH_BATTERY_LEVEL:
                read_battery_status ();
                return;
            case Cinder.EmberMug.PushEvent.CHARGING:
                device_charging ();
                return;
            case Cinder.EmberMug.PushEvent.NOT_CHARGING:
                device_not_charging ();
                return;
            case Cinder.EmberMug.PushEvent.REFRESH_TARGET_TEMPERATURE:
                read_target_temperature ();
                return;
            case Cinder.EmberMug.PushEvent.REFRESH_CURRENT_TEMPERATURE:
                read_current_temperature ();
                return;
            case Cinder.EmberMug.PushEvent.REFRESH_LIQUID_LEVEL:
                read_liquid_level ();
                return;
            case Cinder.EmberMug.PushEvent.REFRESH_LIQUID_STATE:
                read_liquid_state ();
                break;
            default:
                warning ("Unhandled push event received: %s", event.to_string ());
                break;
        }
    }

    private bool characteristic_belongs_to_service (GLib.DBusInterface characteristic, GLib.DBusInterface service) {
        if (characteristic.get_object () == null || service.get_object () == null) {
            return false;
        }
        return characteristic.get_object ().get_object_path ().contains (service.get_object ().get_object_path ());
    }

    private Cinder.Bluetooth.GattCharacteristic? lookup_characteristic (Cinder.EmberMug.Characteristic characteristic) {
        if (characteristics.has_key (characteristic.to_uuid ())) {
            return characteristics.get (characteristic.to_uuid ());
        }
        return null;
    }

    private void compute_status () {
        if (!device.paired) {
            status = Status.UNPAIRED;
        } else if (device.connected) {
            status = Status.CONNECTED;
        } else {
            status = Status.NOT_CONNECTED;
        }
    }

    private uint8[]? read (Cinder.Bluetooth.GattCharacteristic characteristic) {
        try {
            uint8[] result = characteristic.read_value (new GLib.HashTable<string, GLib.Variant> (null, null));
            if (result == null) {
                // TODO throw error?
                return null;
            }
            return result;
        } catch (GLib.Error e) {
            warning (e.message);
        }
        return null;
    }

    private async uint8[]? read_async (Cinder.Bluetooth.GattCharacteristic characteristic) {
        GLib.SourceFunc callback = read_async.callback;
        uint8[]? result = null;

        new GLib.Thread<bool> ("read-%s".printf (characteristic.UUID), () => {
            result = read (characteristic);
            Idle.add ((owned) callback);
            return true;
        });
        yield;

        return result;
    }

    //  public signal void connected ();
    //  public signal void disconnected ();
    //  public signal void paired ();
    //  public signal void unpaired ();

    public signal void characteristic_ready (Cinder.EmberMug.Characteristic characteristic);

    public signal void battery_status_changed (Cinder.EmberMug.BatteryStatus battery_status);
    public signal void device_charging ();
    public signal void device_not_charging ();

    public signal void liquid_state_changed (Cinder.EmberMug.LiquidState liquid_state);
    public signal void liquid_level_changed (Cinder.EmberMug.LiquidLevel liquid_level);

    public signal void current_temperature_changed (int temperature);
    public signal void target_temperature_changed (int temperature);
    public signal void temperature_unit_changed (Cinder.EmberMug.TemperatureUnit unit);

    public signal void led_color_changed (Gdk.RGBA color);
    public signal void mug_name_changed (string name);

    public signal void firmware_info_changed (Cinder.EmberMug.FirmwareInfo firmware_info);

}