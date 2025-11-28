# Storie

Nim-based engine for building terminal apps and games, with support for both native and WebAssembly targets.

## History

- Successor to [Storiel](https://github.com/maddestlabs/storiel), the Lua-based engine.
- Built from [Backstorie](https://github.com/maddestlabs/Backstorie), a template that builds on concepts from Storiel, providing a more robust foundation for further projects.

## Features

Features carried over from Backstorie:
- **Cross-Platform** - Runs natively in terminals and in web browsers via WebAssembly
- **Modular Architecture** - Platform-specific code cleanly separated for easy maintenance
- **Reusable Libraries** - Helper modules for events, animations, and UI components
- **Input Handling** - Comprehensive keyboard, mouse, and special key support
- **Color Support** - True color (24-bit), 256-color, and 8-color terminal support
- **Layer System** - Z-ordered layers with transparency support
- **Automatic Terminal Resize Handling** - All layers automatically resize when the terminal or browser window changes size
- **Direct Callback Architecture** - Simple onInit/onUpdate/onRender callback system

Storie features:
- Minimal Markdown-like parser
- Nim-based scripting using [Nimini](https://github.com/maddestlabs/nimini)
