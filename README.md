# XRCinemon

XRCinemon is an open-source VR cinema application built with Godot for browsing and watching personal video libraries in immersive virtual environments.

## About

The project explores a VR-native approach to personal video libraries, combining a virtual cinema with a media browser inspired by applications such as Kodi and Plex.

The goal is to make it easy to browse a collection, preview videos, and watch selected content in different virtual spaces.

XRCinemon is a work in progress. Features, architecture, and usability are still evolving.

## Current Status

The application is under active development. Some features are experimental, and the project is not yet ready for general use.

Currently, XRCinemon has only been tested on Linux.

## Requirements

- Godot Engine
- A compatible VR headset and OpenXR runtime (HTC Vive tested)
- Linux (currently the only tested platform)
- `ffmpeg` and `ffprobe` installed in `/usr/bin` for media importing

## Controls

### Left Hand

- Touchpad: Move around in the virtual environment
- Grip: Turn left

### Right Hand

- Trigger: Skip through video content or navigate menus, depending on the active view
- Menu button: Open the menu
- Grip: Turn right

### Both Hands

- Trigger: Select menu buttons and UI elements

## Media Library

XRCinemon supports importing media files into its media library.

The current import implementation uses `ffmpeg` and `ffprobe` to generate previews and retrieve media information. Both executables must be available in `/usr/bin`.

This import workflow is subject to change and may not represent the final implementation.

## Configuration

XRCinemon creates a configuration file at:

`/home/<user>/.XRCinemon/media_library_loader_service.cfg`

This file allows you to configure:

- The source directories used to load and import media files.
- Which favorites are available in the media library.
- Which favorites are automatically detected during media import.
