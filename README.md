![build](https://github.com/milikhin/seabass2/workflows/build/badge.svg)

# Seabass

## About

Seabass is a code editor for mobile devices.

Currently supported platforms:

* Sailfish OS
* UBports

Features:
* Syntax highlighting for over 120 programming/markup languages
* Multiple tabs (UBports only)
* Navigation buttons (Sailfish OS only)
* Undo/Redo
* Light and dark themes

![Seabass on Sailfish X #1](http://milikhin.name/img/seabass/seabass-xperia-04.png)
![Seabass on Sailfish X #2](http://milikhin.name/img/seabass/seabass-xperia-02.png)

## Architecture

Application for each platform consists of two major parts:

1. Platform-specific application  
    The application provides UI using native components, interacts with file system and contains WebView to inject editor engine

1. Web-based editor engine  
    HTML5 application optimised for mobile WebView runtime

The two components interact using a simple message-based API.
In Sailfish OS messages are delivered using `navigator.qt` API

## Directory structure

* `harbour-seabass` - QML application for Sailfish OS developed with Sailfish SDK
* `editor` - JS editor engine

## Build instructions

Requirements:

* Node.js, tested using v12
* Sailfish SDK (for Sailfish OS)
* clickable (for UBports)

Build steps:

1. Building editor engine  
   1. Install editor dependencies and build tools: `npm install`
   1. Build editor engine and copy required files to Sailfish app directory: `npm run build`
1. Build App  
   * Sailfish OS: build `harbour-seabass` using Sailfish SDK
   * UBports: build `ubports-seabass` using clickable

## Documentation

Major design decisions and applied workarounds are listed in [workarounds.md](docs/workarounds.md).
