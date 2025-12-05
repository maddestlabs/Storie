# Storie

Storie is a minimal, hackable engine designed for fast prototyping with a clear path to native compilation. Built with [Nim](https://nim-lang.org/), it lets you write markdown with executable code blocks in various, simplified languages via [Nimini](https://github.com/maddestlabs/nimini). Storie uses [raylib](https://www.raylib.com/) by default and compiles to native binaries or WebAssembly. Swap backends (Raylib/SDL3), modify anything, break things. It's made for tinkerers who want zero constraints.

Check it out live: [Demo](https://maddestlabs.github.io/storie/)

The engine is built around GitHub features. No need to actually install Nim, or anything for that matter. Just create a new repo from the Storie template, update index.md with your own content and it'll auto-compile for the web. Enable GitHub Pages and you'll see that content served live within moments. GitHub Actions take care of the full compilation process.

## Features

Core engine features:
- **Cross-Platform** - Runs natively and in web browsers via WebAssembly
- **Fast-Prototyping** - Write code on GitHub Gist and see it run live. [Example](https://maddestlabs.github.io/storie?gist=bd236fe257f02e371e04f7d9899be0c2) | [Source Gist](https://gist.github.com/R3V1Z3/bd236fe257f02e371e04f7d9899be0c2)
- **Built with Nim** - Highly readable code that compiles fast and produces small binaries/executables

## Getting Started

Quick Start:
- Create a gist using Markdown and Nim code blocks
- See your gist running live: `https://maddestlabs.github.io/Storie?gist=GistID`

Create your own project:
- Create a template from Storie and enable GitHub Pages
- Update index.md with your content and commit the change
- See your content running live in moments

Native compilation:
- In your repo, go to Actions -> Export Code and get the exported code
- Install Nim locally
- Replace index.nim with your exported code
- On Linux: `./build.sh`. Windows: `build-win.bat`. For web: `./build-web.sh`

You'll get a native compiled binary in just moments, Nim compiles super fast.

## History

- Successor to [Storiel](https://github.com/maddestlabs/storiel), the terminal based proof-of-concept with Lua scripting.
- Rebuilt from [Backstorie](https://github.com/maddestlabs/backstorie), a terminal focused template providing a more robust foundation for further projects.
