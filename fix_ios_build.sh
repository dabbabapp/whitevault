#!/bin/bash

# Fix for Xcode 15+ compiler issues with Flutter iOS builds
# This script removes problematic compiler flags that cause build failures

echo "Fixing Xcode 15+ compiler issues..."

# Navigate to iOS directory
cd ios

# Remove problematic flags from all .xcconfig files
find . -name "*.xcconfig" -exec sed -i '' 's/-G//g' {} \;

# Remove problematic flags from project.pbxproj
find . -name "project.pbxproj" -exec sed -i '' 's/-G//g' {} \;

# Clean and reinstall pods
echo "Cleaning and reinstalling pods..."
pod deintegrate
rm -rf Pods
rm Podfile.lock
pod install

echo "Fix completed. You can now try building again."
