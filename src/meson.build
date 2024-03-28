# SPDX-FileCopyrightText: 2024 Andrew Vojak
# SPDX-License-Identifier: GPL-3.0-or-later

conf_data = configuration_data()
conf_data.set('APP_ID', application_id)
conf_data.set('APP_NAME', application_name)
conf_data.set('VERSION', '@0@@1@'.format(meson.project_version(), version_suffix))
conf_data.set('RESOURCE_PATH', application_resource_path)
conf_data.set('DEVELOPER_NAME', 'Andrew Vojak')
conf_data.set('DEVELOPER_EMAIL', 'andrew.vojak@gmail.com')
conf_data.set('DEVELOPER_WEBSITE', 'https://avojak.com')

config_header = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

cinder_files = files(
    'Models' / 'EmberMug.vala',
    'Services' / 'Bluetooth' / 'Adapter.vala',
    'Services' / 'Bluetooth' / 'AdvertisementMonitor.vala',
    'Services' / 'Bluetooth' / 'AdvertisementMonitorManager.vala',
    'Services' / 'Bluetooth' / 'Agent.vala',
    'Services' / 'Bluetooth' / 'AgentManager.vala',
    'Services' / 'Bluetooth' / 'Device.vala',
    'Services' / 'Bluetooth' / 'EmberDeviceManager.vala',
    'Services' / 'Bluetooth' / 'GattCharacteristic.vala',
    'Services' / 'Bluetooth' / 'GattDescriptor.vala',
    'Services' / 'Bluetooth' / 'GattService.vala',
    # 'Services' / 'Ember' / 'DeviceManager.vala',
    'Views' / 'DeviceControlView.vala',
    'Views' / 'DeviceListView.vala',
    'Views' / 'PresetsPage.vala',
    'Views' / 'TemperatureControlPage.vala',
    'Views' / 'WelcomeView.vala',
    'Widgets' / 'ColorChooserDialog.vala',
    'Widgets' / 'EmberDeviceRow.vala',
    'Widgets' / 'HsvColorChooser.vala',
    'Widgets' / 'PresetCard.vala',
    'Widgets' / 'TemperatureControl.vala',
    'Application.vala',
    'MainWindow.vala',
    'Settings.vala',
    'Utils.vala'
)

executable(
    application_id,
    cinder_files,
    config_header,
    asresources,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk4', version: '>= 4.11.3'),
        dependency('gee-0.8'),
        dependency('libevdev'),
        dependency('libadwaita-1', version: '>= 1.4.alpha'),
        meson.get_compiler('vala').find_library('linux'),
        meson.get_compiler('vala').find_library('posix'),
        meson.get_compiler('c').find_library('m')
    ],
    vala_args: vala_args,
    install: true
)