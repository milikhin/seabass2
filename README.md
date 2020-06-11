![build](https://github.com/milikhin/seabass2/workflows/build/badge.svg)

# Seabass
## About

Seabass is a code editor for mobile devices.

Currently supported platforms:

* Sailfish OS
* UBports

[![OpenStore](https://open-store.io/badges/en_US.png)](https://open-store.io/app/seabass2.mikhael)

![Seabass on UBports](https://milikhin.name/img/seabass/seabass-desktop-03.png)

## Features
Core features:
* Syntax highlighting for over 120 programming/markup languages
* Navigation buttons
* Light and dark themes
* Code autocompletion and snippets

UBports:
* Adaptive layout and multiple tabs
* Ability to create new files

## Build instructions

Requirements:

* Node.js, tested using v12
* Sailfish SDK (for Sailfish OS)
* clickable (for UBports)

Build steps:

1. Build editor engine  
   1. Install editor dependencies and build tools: `npm install`
   1. Build editor engine and copy required files to Sailfish/UBports app directory: `npm run build`
1. Build App  
   * Sailfish OS: build `harbour-seabass` using Sailfish SDK
   * UBports: run `clickable`

Running tests:

1. Editor: `npm test`
1. UBports: `clickable test`

## Contribution

Your reviews, bug reports and feature requests are very appreciated!
As so pull requests :-). Please see [wiki](https://github.com/milikhin/seabass2/wiki) for project docs. Unit tests for [editor](https://github.com/milikhin/seabass2/tree/master/editor/__tests__) and [ubports-seabass](https://github.com/milikhin/seabass2/tree/master/ubports-seabass/tests) might also be useful.

There are a few labels used to indicate issue progress.
* `help wanted`: in my opinion, the issue is worth fixing, but I'm not going to fix it myself due to its complexity, time required, if I just don't know how to fix it, or everything above. Pull requests are welcome if you'd like to see the feature implemented!
* `wontfix`: in my opinion, the issue requires to much work out of the project's scope or too many workarounds for SDK issues. Pull requests are still welcome though. It might be worth discussing implementation beforehand if there going to be lots of changes.

## Credits

* [Danfro](https://github.com/Danfro): basic internationalization and German translation for ubports-seabass
* [Pohli](https://github.com/Pohli): testing harbour-seabass
