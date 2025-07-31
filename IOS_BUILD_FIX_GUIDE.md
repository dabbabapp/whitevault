# iOS Build Issues Fix Guide

## Current Issue
We're encountering a known issue with Xcode 15+ and Flutter iOS builds where the compiler flag `-G` is not supported for the arm64-apple-ios12.0 target. This is commonly caused by the gRPC library dependencies.

## Immediate Solution: Build in Xcode

Since `flutter build ios --release` is failing, we'll build directly in Xcode:

### Step 1: Open Xcode
The Xcode workspace should already be open. If not:
```bash
open ios/Runner.xcworkspace
```

### Step 2: Configure Build Settings in Xcode

1. **Select Runner project** (blue icon) in the left sidebar
2. **Select Runner target** under Targets
3. **Go to Build Settings tab**
4. **Search for "Other C Flags"**
5. **Remove any "-G" flags** if present
6. **Search for "Other C++ Flags"**
7. **Remove any "-G" flags** if present

### Step 3: Build for Archive

1. **Select "Any iOS Device (arm64)" from the scheme selector** (top-left in Xcode)
2. **Go to Product → Archive**
3. **Wait for the build to complete**

### Step 4: If Archive Succeeds

1. **Xcode Organizer will open automatically**
2. **Select your archive**
3. **Click "Distribute App"**
4. **Choose "App Store Connect"**
5. **Follow the upload wizard**

### Step 5: Alternative - Export IPA

If you want to test first:
1. **Click "Distribute App" → "Development"**
2. **Export the IPA file**
3. **Install via Xcode Devices window for testing**

## If Archive Still Fails

Try these additional steps:

### Option A: Update Deployment Target
1. In Xcode, select Runner target
2. Go to "Deployment Info"
3. Change iOS Deployment Target to 13.0 or higher
4. Try archiving again

### Option B: Disable Bitcode (if not already done)
1. Search for "Enable Bitcode" in Build Settings
2. Set to "No" for all configurations

### Option C: Clean Build Folder
1. In Xcode: Product → Clean Build Folder
2. Try archiving again

## Final Notes

- The bundle identifier is set to: `info.whitevault.app`
- Your Apple Developer team is: AHMAD kaATEB
- Make sure your signing is working (no red errors in Signing & Capabilities)

Once you get a successful archive, you can upload to App Store Connect!
