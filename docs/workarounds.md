# Workarounds and Design decisions

## Intro

The document contains explanation of key design decisions and list of various workarounds applied to make the project possible.

## Key principles

The following key principles defines the Seabass architecture:
* Seabass should provide as good UX as possible
* Seabass is a cross platform project. Currently planned target platforms:  
   * Sailfish OS
   * Ubports
* Maintenance should be as simple as possible.
* Build/testing should be as automated as possible.

## Architecture

The key principles principles results in the following decisions.  
The application consists of two components (to provide great UX and cross platform availability the same time):
* Platform-specific application  
   The platform-specific application provides native UI and contains no business logic (editor itself).  
   For the current target platforms it is a pure QML application to keep things simple.
* Platform-agnostic editor engine  
   HTML5 application for the webView provides business logic (editor itself) and no UI.  
   Why HTML5? Because there are great ready to use web-editors available, that have no match among native QML components.
   
Hence all the core functionality is contained in a platform-independend web application.
To keep things simple Seabass relies heavily on upstream code editor component with as few modifications as possible.

UI Application and Editor interacts using `navigation.qt` API available for QML applications.
The API provides a single entry point for HTML application, and can be easilly swapped for another API if needed.
The editor is separated from the API, so editor can also be swapped with another one if needed.

So the only requirements to enable new target platform is a WebView component that could handle HTML5 code editor.

## Workarounds and constraints

Sailfish OS provides pretty outdated QT 5.6 and QtWebKit 3.0 wrapped into own SilicaWebView component.  
This is where things are starting to become quite interesting.  
Various workarounds have been implemented to make the project possible and usable on Sailfish.  
It also means that when a new issue arises chances are that the reason is among these workarounds :-)

* Ace vs Codemirror  
   Scroll doesn't work in Codemirror@5 on Sailfish while Ace is usable, so: **Ace**
   
* WebView scaling  
   By default 1 pixel in CSS equals 1 screen px so viewport is scaled manually using `Screen.width`, `Theme.pixelRatio` and a few magic numbers

* Orientation changing  
   WebView's viewport width must be recalculated when the application window is resized (or device orientation is changed).
   Even after that WebView is not resized properly. The workaround is to change any property that affects webView's size to any value and then quickly restore the correct value back. For example:  
   ```
   page.x = 1
   page.x = 0
   ```

* Reading/Writing files in QML  
   Accessing the device's file system (FS) is possible with `XmlHttpRequest`. `GET` is used to read and `PUT` is used to write files.
   Quite convinient, isn't it? Well, yes! Until we need to find out whether the FS operation has been successful or not.
   For example the `status` for FS write operations is always `0` regardless of any errors.
   The only way I've found (please let me know if there is a better way) to distinquish successfull reads/writes from failed is to check XmlHttpRequest's `readyState` for `HEADERS_RECEIVED` value.  
   ```
   var sentSuccessfully = false
   ...
   // send request...   
   ...
   if (request.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
      sentSuccessfully = true
   }
   if (request.readyState === XMLHttpRequest.DONE) {
       if (!sentSuccessfully) {
           return callback(new Error('Error writing file'))
       }

       // request.readyState has had HEADERS_RECEIVED value before DONE, so everything is OK
       return callback(null, request.responseText)
   }
   ```

* TextSwitch component  
   The component can't be used inline with other controls (for example in a Docked panel).
   The workaround is to hide some of it's nested components.

* Pulley menus in SilicaWebView  
   Pulley menus don't work if the WebView is not scrollable. The workaround is to make web page's height equal to `100% of WebView height` + `1px`

* Scrolling Ace editor in SilicaWebView  
   When the web page is scrolled to the top, scrolling Ace editor top results in opacity applied to the the whole WebView.
   The workaround is to scroll web page using JS 1px down when scrolling Ace top, and 1px up when scrolling Ace down.
