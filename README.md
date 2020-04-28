# Seabass

## About

Seabass is a code editor for mobile devices.

Currently supported platforms:

* Sailfish OS

Features:
* Syntax highlighting for over 120 programming/markup languages
* Native look and feel for each platform

## Architecture

Application for each platform consists of two major parts:

1. Platform-specific application  
    The application provides UI using native components, interacts with file system and contains WebView to inject editor engine

1. Common web-based editor engine  
    HTML5 application optimised for mobile WebView runtime based on the awesome [Ace editor](https://github.com/ajaxorg/ace)

The two components interacts using a simple message-based API.
In Sailfish OS messages are delivered using `navigator.qt` API

## Directory structure

* `harbour-seabass` - QML application for Sailfish OS developed with Sailfish SDK
* `editor` - JS editor engine
