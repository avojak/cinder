![CI](https://github.com/avojak/cinder/workflows/CI/badge.svg)
![Lint](https://github.com/avojak/cinder/workflows/Lint/badge.svg)
![GitHub](https://img.shields.io/github/license/avojak/cinder.svg?color=blue)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/avojak/cinder?sort=semver)

<p align="center">
  <!-- <img src="data/assets/cinder.svg" alt="Icon" /> -->
</p>
<h1 align="center">Cinder</h1>
<p align="center">
  <!-- <a href='https://flathub.org/apps/details/com.avojak.cinder'><img width='155' alt='Download on Flathub' src='https://flathub.org/assets/badges/flathub-badge-en.png'/></a> -->
</p>

## Control your Ember® Mug

## Building

Cinder uses Flatpak for builds and packaging.

To make sure you have the correct Flatpak runtime and SDK installed, run:

```bash
make init
```

To run the Flatpak build, run:

```bash
make flatpak # or just `make`
```

To run with debug logs enabled for development, run:

```bash
make run
```

### Development Environment

For consistency and simplicity, a Visual Studio Code dev container definition is provided. This container contains all the required development libraries, plus some useful Visual Studio Code plugins. When actually developing, however, you'll want to run the build commands from your local host instead of within the container.

## Related Projects

Cinder would not be possible without the efforts of the following projects:

- [Ember Mug Bluetooth Documentation](https://github.com/orlopau/ember-mug) by [Paul Orlob](https://github.com/orlopau)
- [Python Ember Mug](https://github.com/sopelj/python-ember-mug) by [Jesse Sopel](https://github.com/sopelj)
---

## Copyright Notice

Cinder is not affiliated, associated, authorized, endorsed by, or in any way officially connected with Ember Technologies, or any of its subsidiaries or its affiliates. Ember&reg; is a registered trademark of Ember Technologies, Inc.

All other product names mentioned herein, with or without the registered trademark symbol &reg; or trademark symbol &trade; are generally trademarks and/or registered trademarks of their respective owners.
