/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.DeviceControlView : Adw.Bin {

    private Cinder.TemperatureControlPage temperature_control_page;

    construct {
        var carousel = new Adw.Carousel () {
            orientation = Gtk.Orientation.VERTICAL,
            allow_scroll_wheel = true,
            allow_mouse_drag = false,
            interactive = true,
            hexpand = true,
            vexpand = true
        };

        var carousel_indicator = new Adw.CarouselIndicatorDots () {
            orientation = Gtk.Orientation.VERTICAL,
            carousel = carousel
        };

        temperature_control_page = new Cinder.TemperatureControlPage ();
        var presets_page = new Cinder.PresetsPage ();
        presets_page.preset_selected.connect ((temperature) => {
            preset_selected (temperature);
            temperature_control_page.set_target_temperature (temperature);
        });

        carousel.append (temperature_control_page);
        carousel.append (presets_page);

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
        box.append (carousel_indicator);
        box.append (carousel);

        child = box;
    }

    public void set_current_temperature (int temperature) {
        temperature_control_page.set_current_temperature (temperature);
    }

    public void device_empty () {
        temperature_control_page.device_empty ();
    }

    public void device_not_empty () {
        temperature_control_page.device_not_empty ();
    }

    public signal void preset_selected (int temperature);

}