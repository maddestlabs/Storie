# Dynamic Markdown Loading Features

Storie now supports loading custom markdown files in both WASM and desktop versions!

## Desktop Usage

Load a custom markdown file using the `--markdown` or `-m` flag:

```bash
# Using long form
./storie --markdown my_demo.md

# Using short form
./storie -m my_demo.md

# As positional argument
./storie my_demo.md

# Show help
./storie --help
```

## WASM/Web Usage

Load markdown from a GitHub Gist using the `?gist=` URL parameter:

```
https://yoursite.com/storie/?gist=abc123def456
```

### How it works:
1. The page detects the `?gist=` parameter
2. Fetches the gist content from GitHub API
3. Finds the first `.md` file in the gist
4. Loads it dynamically into the running WASM application

### Creating a Shareable Gist:

1. Go to https://gist.github.com/
2. Create a new gist with a `.md` file (e.g., `demo.md`)
3. Write your Storie markdown with code blocks
4. Copy the gist ID from the URL (e.g., `abc123def456`)
5. Share: `https://yoursite.com/storie/?gist=abc123def456`

## Example Markdown Files

### `test_demo.md` - Simple bouncing ball
```markdown
# Test Demo - Custom Markdown

```nim on:render
clear()
clearFg()
setColor(20, 20, 40)
fillRect(0, 0, width, height)

var time = frameCount / 60.0
var ballX = width / 2 + int(sin(time * 3.0) * 300.0)
var ballY = height / 2 + int(cos(time * 2.0) * 200.0)

setColor(255, 100, 100)
fillCircle(ballX, ballY, 50)
\`\`\`
```

### `gist_example.md` - Star pattern
See the included example file for a more complex demo suitable for gist sharing.

## Technical Details

### Desktop Implementation
- Uses Nim's `parseopt` module for command-line parsing
- Reads markdown files from filesystem at runtime
- Falls back to `index.md` if no file specified

### WASM Implementation
- JavaScript fetches gist from `https://api.github.com/gists/{id}`
- Passes markdown content to WASM via `loadMarkdownFromJS()` exported function
- Dynamically reloads and re-initializes code blocks
- Rate limit: 60 requests/hour for unauthenticated requests (sufficient for demos)

## API Rate Limits

GitHub API limits:
- **Unauthenticated**: 60 requests per hour per IP
- **Authenticated**: 5,000 requests per hour

For production use, consider caching gist content or using authenticated requests.

## Error Handling

The system gracefully handles:
- Missing markdown files (desktop)
- Invalid gist IDs (WASM)
- Network errors (WASM)
- Gists without `.md` files
- Malformed markdown syntax

Errors are logged to console and displayed in the status area.
