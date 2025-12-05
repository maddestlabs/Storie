# Native Binary Export via GitHub Actions

This document describes how users can export their Nimini code to native binaries using GitHub Actions.

## Overview

Users can convert their Nimini code (running in WebAssembly) to native executables for Windows, Linux, and macOS through an automated GitHub Actions workflow.

## Architecture

```
User's Browser (Nimini Code)
       ↓
   Web API Endpoint
       ↓
   GitHub Actions Workflow
       ↓
   Native Binary Compilation
       ↓
   GitHub Release with Downloads
```

## Implementation Options

### Option 1: Repository Dispatch (Recommended)

User workflow:
1. User writes Nimini code in web editor
2. Clicks "Export to Native"
3. Web app sends code to backend API
4. Backend triggers GitHub Actions via Repository Dispatch
5. GitHub Actions compiles for multiple platforms
6. Creates a Release with download links
7. User receives email/notification with download link

**Pros:**
- Fully automated
- Multi-platform builds (Windows, Linux, macOS)
- Free for public repos
- Professional CI/CD approach

**Cons:**
- Requires backend API
- GitHub API rate limits
- Build time (2-5 minutes)

### Option 2: Manual GitHub Gist + Actions

User workflow:
1. User creates GitHub Gist with Nimini code
2. User navigates to Storie repo
3. Clicks "Actions" → "Build from Gist"
4. Enters Gist URL
5. Downloads compiled binary from workflow artifacts

**Pros:**
- No backend needed
- Uses GitHub's existing infrastructure

**Cons:**
- Manual steps required
- User needs GitHub account
- Less streamlined UX

### Option 3: CLI Tool (Simplest)

User workflow:
1. Download `storie-cli` once (pre-compiled)
2. Run: `storie-cli export mycode.nim`
3. Get native binary locally

**Pros:**
- Instant compilation
- No network dependency
- Best UX for developers

**Cons:**
- Requires Nim compiler installation
- No web-only workflow
- Platform-specific binaries

## Recommended Approach: Hybrid

1. **For Demos/Quick Testing:** WASM minimal builds (instant, in-browser)
2. **For Native Export:** GitHub Actions + Repository Dispatch
3. **For Power Users:** `storie-cli` tool

## GitHub Actions Workflow Example

```yaml
# .github/workflows/build-native.yml
name: Build Native Binary

on:
  repository_dispatch:
    types: [build-native]
  workflow_dispatch:
    inputs:
      gist_url:
        description: 'GitHub Gist URL with Nimini code'
        required: true

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    
    runs-on: ${{ matrix.os }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Nim
        uses: jiro4989/setup-nim-action@v1
        with:
          nim-version: 'stable'
      
      - name: Fetch user code
        run: |
          # Download Gist or get from dispatch payload
          curl -o user_code.nim ${{ github.event.inputs.gist_url }}
      
      - name: Analyze imports
        run: |
          # Use import analyzer to determine required modules
          nim c -r src/nimini/import_analyzer.nim user_code.nim > imports.txt
      
      - name: Compile native binary
        run: |
          nim c -d:release --opt:size -o:storie_app user_code.nim
      
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: storie-${{ matrix.os }}
          path: storie_app*
  
  release:
    needs: build
    runs-on: ubuntu-latest
    
    steps:
      - name: Download all artifacts
        uses: actions/download-artifact@v4
      
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: user-build-${{ github.run_number }}
          files: |
            storie-*/storie_app*
```

## API Endpoint Design

```typescript
// Backend API endpoint
POST /api/export-native
{
  "code": "fillRect(100, 100, 50, 50)\ndrawText(120, 120, \"Hello!\")",
  "targetLibrary": "raylib", // or "sdl3"
  "email": "user@example.com" // optional notification
}

Response:
{
  "buildId": "build-12345",
  "status": "queued",
  "estimatedTime": 180, // seconds
  "statusUrl": "https://github.com/maddestlabs/Storie/actions/runs/12345"
}
```

## Size Considerations

With optimized imports from the metadata system:

- **Minimal Raylib binary:** ~500KB
- **Minimal SDL3 binary:** ~800KB
- **Full Raylib binary:** ~1.5MB
- **Full SDL3 binary:** ~3-4MB

The import analyzer ensures users only get what they need!

## Security

- Rate limiting on API endpoint (10 builds/hour per IP)
- Code validation before compilation
- Sandboxed build environment (GitHub Actions)
- No arbitrary code execution on server
- All builds are public (in Actions tab)

## Future Enhancements

1. **Direct download from web UI** - Stream binary after compilation
2. **Build caching** - Reuse compilation for identical code
3. **Cross-compilation** - Build all platforms from one trigger
4. **Progressive binary** - Start with minimal, download features on-demand
5. **WebAssembly + Native hybrid** - Ship WASM for web, native for desktop

## Cost Analysis

- **GitHub Actions:** 2,000 free minutes/month for public repos
- **Average build time:** 3 minutes × 3 platforms = 9 minutes
- **Capacity:** ~220 user builds per month (free tier)
- **Cost per build:** $0 (public repo)

For private repos or higher volume:
- GitHub Actions: $0.008/minute
- Cost per multi-platform build: ~$0.07

## Next Steps

1. ✅ Build scripts (minimal/full) - Done
2. ✅ Binding metadata system - Done
3. ✅ Import analyzer - Done
4. 🔄 Create GitHub Actions workflow
5. 🔄 Build backend API endpoint
6. 🔄 Integrate into web UI
