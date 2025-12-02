# Quick Start: Creating a Shareable Gist

## Step 1: Create Your Demo

Write your Storie demo in markdown with Nim code blocks:

```markdown
# My Awesome Demo

This is my creative coding demo!

\`\`\`nim on:init
print("Demo started!")
\`\`\`

\`\`\`nim on:render
clear()
clearFg()

# Your rendering code here
setColor(255, 0, 0)
fillCircle(width / 2, height / 2, 50)
\`\`\`
```

## Step 2: Create a GitHub Gist

1. Go to https://gist.github.com/
2. Click "Create a new gist"
3. Add a filename ending in `.md` (e.g., `demo.md`)
4. Paste your markdown content
5. Choose "Create public gist" or "Create secret gist"

## Step 3: Get the Gist ID

After creating, your URL will look like:
```
https://gist.github.com/username/abc123def456789
                                 ^^^^^^^^^^^^^^^^^^
                                 This is your gist ID
```

## Step 4: Share Your Demo

Share this URL:
```
https://yoursite.com/storie/?gist=abc123def456789
```

Or for local testing:
```
http://localhost:8080/?gist=abc123def456789
```

## Example Gists to Try

You can use these examples as templates:

### Simple Animation
```markdown
# Bouncing Ball

\`\`\`nim on:render
clear()
var time = frameCount / 60.0
var x = width / 2 + int(sin(time * 2.0) * 200.0)
var y = height / 2
setColor(255, 100, 100)
fillCircle(x, y, 30)
\`\`\`
```

### Particle System
```markdown
# Particles

\`\`\`nim on:render
clear()
for i in 0 .. 99:
  var time = frameCount / 60.0 + i * 0.1
  var x = width / 2 + int(sin(time) * 300.0)
  var y = height / 2 + int(cos(time * 0.7) * 200.0)
  setColor(100 + i * 2, 150, 255)
  fillCircle(x, y, 5)
\`\`\`
```

### Interactive Text
```markdown
# Hello World

\`\`\`nim on:render
clear()
setColor(0, 0, 40)
fillRect(0, 0, width, height)

var time = frameCount / 60.0
var hue = (frameCount % 360) / 360.0
var r = int(sin(hue * 6.28) * 127.5 + 127.5)
var g = int(sin((hue + 0.333) * 6.28) * 127.5 + 127.5)
var b = int(sin((hue + 0.666) * 6.28) * 127.5 + 127.5)

setColor(r, g, b)
drawText(width / 2 - 100, height / 2, "HELLO STORIE!", 32)
\`\`\`
```

## Tips

### Lifecycle Hooks
- `on:init` - Runs once at startup
- `on:render` - Runs every frame (60fps)
- `on:update` - Runs in fixed timestep
- `on:input` - Runs on keyboard input
- `on:shutdown` - Runs on exit

### Available Functions

**Drawing:**
- `clear()` / `clearFg()`
- `setColor(r, g, b)`
- `fillRect(x, y, w, h)`
- `drawRect(x, y, w, h, lineWidth)`
- `fillCircle(x, y, radius)`
- `drawCircle(x, y, radius, lineWidth)`
- `drawLine(x1, y1, x2, y2, lineWidth)`
- `drawText(x, y, text, size)`
- `drawPixel(x, y)`

**Variables:**
- `width` / `height` - Screen dimensions
- `frameCount` - Total frames rendered
- `fps` - Current frame rate

**Math:**
- `sin(x)` / `cos(x)`
- Standard Nim math operations

### Debugging

Add print statements:
```nim
print("X position: " & $x)
```

Output appears in browser console (F12).

## Updating Your Gist

1. Edit the gist on GitHub
2. Save changes
3. Refresh your demo URL
4. The new content loads automatically!

No recompilation needed! 🎉

## Troubleshooting

**"Gist not found"**
- Check the gist ID is correct
- Ensure the gist is public or you're logged in

**"No .md file found"**
- Make sure your gist has at least one `.md` file
- Check the filename ends with `.md`

**"Error loading gist"**
- Check browser console (F12) for details
- GitHub API may be rate limited (60/hour)
- Check network connection

**Code not running**
- Verify your code blocks start with ` ```nim`
- Check for syntax errors in your Nim code
- Add lifecycle hooks: `on:init`, `on:render`, etc.

## Advanced: Multiple Files

If your gist has multiple `.md` files, the first one alphabetically is loaded.

To control which file loads, name them:
- `01-main.md` (loads first)
- `02-alternative.md`
- `03-another.md`

## Happy Creating! 🎨

Start with simple examples and build up to more complex demos. Share your creations and inspire others!
