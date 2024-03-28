/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.Bluetooth.EmberDeviceManager : GLib.Object {

    //  public bool discoverable { get; set; default = false; }

    //  public bool is_powered {get; private set; default = false; }
    //  public bool is_connected {get; private set; default = false; }

    //  private Gee.Map<string, Gee.List<Cinder.Bluetooth.GattService>> gatt_services_by_device_mac_address;
    //  private Gee.Map<GLib.ObjectPath, Gee.List<Cinder.Bluetooth.GattCharacteristic>> gatt_characteristics_by_service_path;
    //  private Gee.Map<GLib.ObjectPath, Gee.List<Cinder.Bluetooth.GattDescriptor>> gatt_descriptors_by_characteristic_path;

    private Gee.List<Cinder.Bluetooth.GattService> unassigned_services;
    private Gee.List<Cinder.Bluetooth.GattCharacteristic> unassigned_characteristics;
    //  private Gee.List<Cinder.Bluetooth.GattDescriptor> unassigned_descriptors;

    private Gee.List<Cinder.Bluetooth.GattCharacteristic> characteristics;

    private GLib.DBusObjectManagerClient object_manager;

    //  private Gee.List<Cinder.EmberMug> known_mugs;
    private Gee.Map<Cinder.Bluetooth.Device, Cinder.EmberMug> known_mugs;

    construct {
        //  gatt_services_by_device_mac_address = new Gee.HashMap<string, Gee.List<Cinder.Bluetooth.GattService>> ();
        //  gatt_characteristics_by_service_path = new Gee.HashMap<GLib.ObjectPath, Gee.List<Cinder.Bluetooth.GattCharacteristic>> ();
        //  gatt_descriptors_by_characteristic_path = new Gee.HashMap<GLib.ObjectPath, Gee.List<Cinder.Bluetooth.GattDescriptor>> ();
        
        //  known_mugs = new Gee.ArrayList<Cinder.EmberMug> ();
        known_mugs = new Gee.HashMap<Cinder.Bluetooth.Device, Cinder.EmberMug> ();

        unassigned_services = new Gee.ConcurrentList<Cinder.Bluetooth.GattService> ();
        unassigned_characteristics = new Gee.ConcurrentList<Cinder.Bluetooth.GattCharacteristic> ();
        //  unassigned_descriptors = new Gee.ArrayList<Cinder.Bluetooth.GattDescriptor> ();

        characteristics = new Gee.ConcurrentList<Cinder.Bluetooth.GattCharacteristic> (); 

        create_manager.begin ();
    }

    //  public void start () {
        //  create_manager.begin ();
    //  }

    private async void create_manager () {
        try {
            object_manager = yield new GLib.DBusObjectManagerClient.for_bus (
                GLib.BusType.SYSTEM,
                GLib.DBusObjectManagerClientFlags.NONE,
                "org.bluez",
                "/",
                object_manager_proxy_get_type,
                null
            );
            if (object_manager == null) {
                return;
            }
            object_manager.get_objects ().foreach ((object) => {
                object.get_interfaces ().foreach ((iface) => on_interface_added (object, iface));
            });
            object_manager.interface_added.connect (on_interface_added);
            object_manager.interface_removed.connect (on_interface_removed);
            object_manager.object_added.connect ((object) => {
                object.get_interfaces ().foreach ((iface) => on_interface_added (object, iface));
            });
            object_manager.object_removed.connect ((object) => {
                object.get_interfaces ().foreach ((iface) => on_interface_removed (object, iface));
            });
        } catch (GLib.Error e) {
            critical (e.message);
        }
    }

    // TODO: Do not rely on this when it is possible to do it natively in Vala
    [CCode (cname="cinder_bluetooth_device_proxy_get_type")]
    extern static GLib.Type get_device_proxy_type ();

    [CCode (cname="cinder_bluetooth_adapter_proxy_get_type")]
    extern static GLib.Type get_adapter_proxy_type ();

    [CCode (cname="cinder_bluetooth_agent_manager_proxy_get_type")]
    extern static GLib.Type get_agent_manager_proxy_type ();

    [CCode (cname="cinder_bluetooth_gatt_service_proxy_get_type")]
    extern static GLib.Type get_gatt_service_proxy_type ();

    [CCode (cname="cinder_bluetooth_gatt_characteristic_proxy_get_type")]
    extern static GLib.Type get_gatt_characteristic_proxy_type ();

    [CCode (cname="cinder_bluetooth_gatt_descriptor_proxy_get_type")]
    extern static GLib.Type get_gatt_descriptor_proxy_type ();

    [CCode (cname="cinder_bluetooth_advertisement_monitor_proxy_get_type")]
    extern static GLib.Type get_advertisement_monitor_proxy_type ();

    [CCode (cname="cinder_bluetooth_advertisement_monitor_manager_proxy_get_type")]
    extern static GLib.Type get_advertisement_monitor_manager_proxy_type ();

    private GLib.Type object_manager_proxy_get_type (GLib.DBusObjectManagerClient manager, string object_path, string? interface_name) {
        if (interface_name == null) {
            return typeof (GLib.DBusObjectProxy);
        }

        switch (interface_name) {
            case "org.bluez.Device1":
                return get_device_proxy_type ();
            case "org.bluez.Adapter1":
                return get_adapter_proxy_type ();
            case "org.bluez.AgentManager1":
                return get_agent_manager_proxy_type ();
            case "org.bluez.GattService1":
                return get_gatt_service_proxy_type ();
            case "org.bluez.GattCharacteristic1":
                return get_gatt_characteristic_proxy_type ();
            case "org.bluez.GattDescriptor1":
                return get_gatt_descriptor_proxy_type ();
            //  case "org.bluez.AdvertisementMonitor1":
            //      return get_advertisement_monitor_proxy_type ();
            //  case "org.bluez.AdvertisementMonitorManager1":
            //      return get_advertisement_monitor_manager_proxy_type ();
            default:
                return typeof (GLib.DBusProxy);
        }
    }

    private void on_interface_added (GLib.DBusObject object, GLib.DBusInterface iface) {
        if (iface is Cinder.Bluetooth.Device) {
            unowned Cinder.Bluetooth.Device device = (Cinder.Bluetooth.Device) iface;
            if (device.manufacturer_data == null) {
                return;
            }
            if (!device.manufacturer_data.contains (EMBER_BLE_SIG_ID)) {
                return;
            }
            if (device.advertising_data != null) {
                foreach (var key in device.advertising_data.get_keys ()) {
                    debug (key.to_string ());
                }
            }
            debug ("Ember found: %s [paired = %s] [connected = %s] [address = %s]".printf (
                device.alias,
                device.paired.to_string (),
                device.connected.to_string (), 
                device.address));

            var mug = new Cinder.EmberMug.for_device (device) {
                paired = device.paired,
                connected = device.connected
            };
            //  known_mugs.add (mug);
            known_mugs.set (device, mug);
            process_unassigned_services ();

            device_found (mug);
            ((DBusProxy) device).g_properties_changed.connect ((changed, invalid) => {
                var connected = changed.lookup_value ("Connected", GLib.VariantType.BOOLEAN);
                if (connected != null) {
                    debug ("%s [address = %s] connected = %s".printf (device.alias, device.address, device.connected.to_string ()));
                    mug.connected = device.connected;
                    //  check_global_state ();
                    //  if (device.connected) {
                    //      //  device_connected (device);
                    //      mug.connected ();
                    //  } else {
                    //      //  device_disconnected (device);
                    //      mug.disconnected ();
                    //  }
                }

                var paired = changed.lookup_value ("Paired", GLib.VariantType.BOOLEAN);
                if (paired != null) {
                    debug ("%s [address = %s] paired = %s".printf (device.alias, device.address, device.paired.to_string ()));
                    //  check_global_state ();
                    mug.paired = device.paired;
                    //  if (device.paired) {
                    //      mug.paired ();
                    //  } else {
                    //      mug.unpaired ();
                    //  }
                }
            });

            //  check_global_state ();
        } else if (iface is Cinder.Bluetooth.Adapter) {
            // TODO
        } else if (iface is Cinder.Bluetooth.GattCharacteristic) {
            unowned Cinder.Bluetooth.GattCharacteristic characteristic = (Cinder.Bluetooth.GattCharacteristic) iface;

            //  debug (characteristic.UUID);

            foreach (var mug in known_mugs.values) {
                if (mug.supports_characteristic (characteristic)) {
                    mug.register_characteristic (characteristic);
                    return;
                }
            }
            
            unassigned_characteristics.add (characteristic);

        } else if (iface is Cinder.Bluetooth.GattService) {
            unowned Cinder.Bluetooth.GattService service = (Cinder.Bluetooth.GattService) iface;
            if (!Cinder.EmberMug.Service.get_all_uuids ().contains (service.UUID)) {
                return;
            }

            var mac_address = Cinder.Utils.get_mac_address_for_device_path (service.device);
            foreach (var mug in known_mugs.values) {
                if (mug.device.address == mac_address) {
                    mug.register_service (service);
                    process_unassigned_characteristics ();
                    return;
                }
            }

            unassigned_services.add (service);

        //  } else if (iface is Cinder.Bluetooth.GattDescriptor) {
        //      unowned Cinder.Bluetooth.GattDescriptor descriptor = (Cinder.Bluetooth.GattDescriptor) iface;
        //      debug ("GATT descriptor: %s [characteristic = %s]".printf (descriptor.UUID, descriptor.characteristic));

        //      if (!gatt_descriptors_by_characteristic_path.has_key (descriptor.characteristic)) {
        //          gatt_descriptors_by_characteristic_path.set (descriptor.characteristic, new Gee.ArrayList<Cinder.Bluetooth.GattDescriptor> ());
        //      }
        //      gatt_descriptors_by_characteristic_path.get (descriptor.characteristic).add (descriptor);
        } else if (iface is Cinder.Bluetooth.AdvertisementMonitor) {
            unowned Cinder.Bluetooth.AdvertisementMonitor monitor = (Cinder.Bluetooth.AdvertisementMonitor) iface;
            debug ("monitor found");
        } else if (iface is Cinder.Bluetooth.AdvertisementMonitorManager) {
            debug ("monitor manager");
        }
    }

    private void on_interface_removed (GLib.DBusObject object, GLib.DBusInterface iface) {
        if (iface is Cinder.Bluetooth.Device) {
            unowned Cinder.Bluetooth.Device device = (Cinder.Bluetooth.Device) iface;
            if (device.manufacturer_data == null) {
                return;
            }
            if (!device.manufacturer_data.contains (EMBER_BLE_SIG_ID)) {
                return;
            }
            debug ("Ember removed: %s [paired = %s] [connected = %s] [address = %s]".printf (
                device.alias,
                device.paired.to_string (),
                device.connected.to_string (), 
                device.address));

            //  lock (known_mugs) {
            foreach (var entry in known_mugs.entries) {
                if (entry.key == device) {
                    Cinder.EmberMug mug;
                    known_mugs.unset (device, out mug);
                    device_removed (mug);
                }
            }
            //  }
            
            //  device_removed ((Cinder.Bluetooth.Device) iface);
        //  } else if (iface is Cinder.Bluetooth.Adapter) {
        //      // TODO
        }
    }

    private void process_unassigned_services () {
        foreach (var service in unassigned_services) {
            var mac_address = Cinder.Utils.get_mac_address_for_device_path (service.device);
            foreach (var entry in known_mugs.entries) {
                if (entry.key.address == mac_address) {
                    entry.value.register_service ((owned) service);
                    unassigned_services.remove (service);
                }
            }
        }

        process_unassigned_characteristics ();
    }

    private void process_unassigned_characteristics () {
        foreach (var characteristic in unassigned_characteristics) {
            foreach (var entry in known_mugs.entries) {
                if (entry.value.supports_characteristic (characteristic)) {
                    entry.value.register_characteristic ((owned) characteristic);
                    unassigned_characteristics.remove (characteristic);
                }
            }
        }
    }

    //  public void check_global_state () {
    //      /* As this is called within a signal handler and emits a signal
    //       * it should be in a Idle loop  else races occur */
    //      Idle.add (() => {
    //          var powered = get_global_state ();
    //          var connected = get_connected ();

    //          /* Only signal if actually changed */
    //          if (powered != is_powered || connected != is_connected) {
    //              if (!powered) {
    //                  discoverable = false;
    //              }

    //              is_connected = connected;
    //              is_powered = powered;
    //          }

    //          return false;
    //      });
    //  }

    //  public Gee.LinkedList<Cinder.Bluetooth.Adapter> get_adapters () {
    //      var adapters = new Gee.LinkedList<Cinder.Bluetooth.Adapter> ();
    //      if (object_manager != null) {
    //          object_manager.get_objects ().foreach ((object) => {
    //              GLib.DBusInterface? iface = object.get_interface ("org.bluez.Adapter1");
    //              if (iface == null)
    //                  return;

    //              adapters.add (((Cinder.Bluetooth.Adapter) iface));
    //          });
    //      }

    //      return (owned) adapters;
    //  }

    //  public Gee.Collection<Cinder.Bluetooth.Device> get_devices () {
    //      var devices = new Gee.LinkedList<Cinder.Bluetooth.Device> ();
    //      if (object_manager != null) {
    //          object_manager.get_objects ().foreach ((object) => {
    //              GLib.DBusInterface? iface = object.get_interface ("org.bluez.Device1");
    //              if (iface == null)
    //                  return;

    //              devices.add (((Cinder.Bluetooth.Device) iface));
    //          });
    //      }

    //      return (owned) devices;
    //  }

    //  public bool get_connected () {
    //      var devices = get_devices ();
    //      foreach (var device in devices) {
    //          if (device.connected) {
    //              return true;
    //          }
    //      }

    //      return false;
    //  }

    //  public bool get_global_state () {
    //      var adapters = get_adapters ();
    //      foreach (var adapter in adapters) {
    //          if (adapter.powered) {
    //              return true;
    //          }
    //      }

    //      return false;
    //  }

    public signal void device_found (Cinder.EmberMug mug);
    public signal void device_removed (Cinder.EmberMug mug);

    //  public signal void device_found (Cinder.Bluetooth.Device device);
    //  public signal void device_removed (Cinder.Bluetooth.Device device);

    //  public signal void service_added(Cinder.Bluetooth.GattService service);
    //  public signal void service_removed(Cinder.Bluetooth.GattService service);
    //  public signal void characteristic_added(Cinder.Bluetooth.GattCharacteristic characteristic);
    //  public signal void characteristic_removed(Cinder.Bluetooth.GattCharacteristic characteristic);
    //  public signal void descriptor_added(Cinder.Bluetooth.GattDescriptor descriptor);
    //  public signal void descriptor_removed(Cinder.Bluetooth.GattDescriptor descriptor);

    //  public signal void device_connected (Cinder.Bluetooth.Device device);
    //  public signal void device_disconnected (Cinder.Bluetooth.Device device);

}