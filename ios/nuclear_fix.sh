#!/bin/bash

echo "🔥 NUCLEAR FIX: Removing ALL -G flags from all pod files..."

# Find and replace all instances of -G flags in all pod files
find Pods/ -name "*.xcconfig" -exec sed -i '' 's/-G[^ ]*//g' {} \;
find Pods/ -name "*.xcodeproj" -exec find {} -name "*.pbxproj" -exec sed -i '' 's/-G[^ ]*//g' {} \;

# Also fix any build settings files
find Pods/ -name "*.build" -exec find {} -name "*.xcconfig" -exec sed -i '' 's/-G[^ ]*//g' {} \; 2>/dev/null

echo "✅ Nuclear fix complete. Try building in Xcode now."
