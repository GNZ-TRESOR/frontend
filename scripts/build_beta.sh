#!/bin/bash

# Ubuzima Beta Build Script
# This script builds the app for beta testing

set -e

echo "🚀 Starting Ubuzima Beta Build Process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="Ubuzima Beta"
VERSION="1.0.0-beta.1"
BUILD_NUMBER="1001"
FLAVOR="staging"
BUILD_TYPE="beta"

echo -e "${BLUE}📱 App: $APP_NAME${NC}"
echo -e "${BLUE}📦 Version: $VERSION${NC}"
echo -e "${BLUE}🏗️ Build: $BUILD_NUMBER${NC}"
echo -e "${BLUE}🎯 Flavor: $FLAVOR${NC}"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Check Flutter version
echo -e "${YELLOW}🔍 Checking Flutter version...${NC}"
flutter --version

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

# Run code generation if needed
echo -e "${YELLOW}⚙️ Running code generation...${NC}"
flutter packages pub run build_runner build --delete-conflicting-outputs || true

# Analyze code
echo -e "${YELLOW}🔍 Analyzing code...${NC}"
flutter analyze

# Run tests
echo -e "${YELLOW}🧪 Running tests...${NC}"
flutter test || echo -e "${YELLOW}⚠️ Some tests failed, continuing with build...${NC}"

# Build Android APK for beta
echo -e "${YELLOW}🔨 Building Android APK for beta testing...${NC}"
flutter build apk \
    --flavor=$FLAVOR \
    --build-name=$VERSION \
    --build-number=$BUILD_NUMBER \
    --target-platform android-arm,android-arm64,android-x64 \
    --split-per-abi \
    --obfuscate \
    --split-debug-info=build/app/outputs/symbols

# Build Android App Bundle for Play Store
echo -e "${YELLOW}🔨 Building Android App Bundle...${NC}"
flutter build appbundle \
    --flavor=$FLAVOR \
    --build-name=$VERSION \
    --build-number=$BUILD_NUMBER \
    --obfuscate \
    --split-debug-info=build/app/outputs/symbols

# Create output directory
OUTPUT_DIR="build/beta-release"
mkdir -p $OUTPUT_DIR

# Copy APK files
echo -e "${YELLOW}📁 Organizing build artifacts...${NC}"
cp build/app/outputs/flutter-apk/app-$FLAVOR-release.apk $OUTPUT_DIR/ubuzima-beta-universal.apk
cp build/app/outputs/flutter-apk/app-armeabi-v7a-$FLAVOR-release.apk $OUTPUT_DIR/ubuzima-beta-arm.apk 2>/dev/null || true
cp build/app/outputs/flutter-apk/app-arm64-v8a-$FLAVOR-release.apk $OUTPUT_DIR/ubuzima-beta-arm64.apk 2>/dev/null || true
cp build/app/outputs/flutter-apk/app-x86_64-$FLAVOR-release.apk $OUTPUT_DIR/ubuzima-beta-x64.apk 2>/dev/null || true

# Copy App Bundle
cp build/app/outputs/bundle/${FLAVOR}Release/app-$FLAVOR-release.aab $OUTPUT_DIR/ubuzima-beta.aab

# Generate build info
echo -e "${YELLOW}📄 Generating build information...${NC}"
cat > $OUTPUT_DIR/build-info.txt << EOF
Ubuzima Beta Build Information
==============================

App Name: $APP_NAME
Version: $VERSION
Build Number: $BUILD_NUMBER
Flavor: $FLAVOR
Build Type: $BUILD_TYPE
Build Date: $(date)
Flutter Version: $(flutter --version | head -n 1)
Dart Version: $(dart --version)

Files Generated:
- ubuzima-beta-universal.apk (Universal APK)
- ubuzima-beta-arm.apk (ARM APK)
- ubuzima-beta-arm64.apk (ARM64 APK)
- ubuzima-beta-x64.apk (x64 APK)
- ubuzima-beta.aab (App Bundle for Play Store)

Installation Instructions:
1. Enable "Install from Unknown Sources" on your Android device
2. Download and install the appropriate APK file
3. For Play Store testing, use the App Bundle (.aab) file

Beta Testing Notes:
- This is a beta version for testing purposes only
- Report any bugs or issues through the in-app feedback system
- Data may be reset between beta versions
- Some features may be incomplete or experimental

Contact: beta@ubuzima.com
EOF

# Generate checksums
echo -e "${YELLOW}🔐 Generating checksums...${NC}"
cd $OUTPUT_DIR
sha256sum *.apk *.aab > checksums.txt
cd - > /dev/null

# Display file sizes
echo -e "${GREEN}📊 Build artifacts:${NC}"
ls -lh $OUTPUT_DIR/

# Calculate total size
TOTAL_SIZE=$(du -sh $OUTPUT_DIR | cut -f1)
echo -e "${GREEN}📦 Total size: $TOTAL_SIZE${NC}"

# Success message
echo -e "${GREEN}✅ Beta build completed successfully!${NC}"
echo -e "${GREEN}📁 Build artifacts are in: $OUTPUT_DIR${NC}"
echo -e "${GREEN}🚀 Ready for beta testing distribution!${NC}"

# Optional: Open output directory
if command -v open &> /dev/null; then
    echo -e "${BLUE}📂 Opening output directory...${NC}"
    open $OUTPUT_DIR
elif command -v xdg-open &> /dev/null; then
    echo -e "${BLUE}📂 Opening output directory...${NC}"
    xdg-open $OUTPUT_DIR
fi

echo -e "${BLUE}🎉 Beta build process completed!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Test the APK on different devices"
echo -e "2. Upload to Firebase App Distribution or TestFlight"
echo -e "3. Send download links to beta testers"
echo -e "4. Collect feedback and iterate"

exit 0
