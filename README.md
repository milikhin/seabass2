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

1. Platform-specific "frontend" application  
    Frontend application provides UI using native components and contains WebView to inject editor engine

1. Common web-based "backend" editor engine  
    Backend is a HTML5 application based on the awesome [Ace editor](https://github.com/ajaxorg/ace) optimised for mobile WebView runtime 

Frontend and backend components interacts using the simple message-based API.
In Sailfish OS messages are delivered using `navigator.qt` API

## Directory structure

* `harbour-seabass` - QML application for Sailfish OS developed with Sailfish SDK
* `editor` - JS editor engine
