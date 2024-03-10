/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Cinder.DeviceControlView : Adw.Bin {

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

        var temperature_control_page = new Cinder.TemperatureControlPage ();
        var presets_page = new Cinder.PresetsPage ();
        carousel.append (temperature_control_page);
        carousel.append (presets_page);

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
        box.append (carousel_indicator);
        box.append (carousel);

        child = box;
    }

}