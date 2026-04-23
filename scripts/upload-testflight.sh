#!/usr/bin/env bash
# Archive + upload IAm to TestFlight via the App Store Connect API.
#
# Prerequisites:
#   - App Store Connect API key (.p8) downloaded to ~/.appstoreconnect/private_keys/
#   - Bundle IDs registered, app record created in App Store Connect
#   - Your Team ID filled into ExportOptions.plist
#
# Usage:
#   export ASC_KEY_ID=ABCDE12345
#   export ASC_ISSUER_ID=69a6de90-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#   ./scripts/upload-testflight.sh
#
# Optional: bump build number automatically
#   BUMP_BUILD=1 ./scripts/upload-testflight.sh

set -euo pipefail

cd "$(dirname "$0")/.."

: "${ASC_KEY_ID:?Set ASC_KEY_ID to your App Store Connect API Key ID}"
: "${ASC_ISSUER_ID:?Set ASC_ISSUER_ID to your App Store Connect Issuer ID}"

PROJECT="IAmWorthy.xcodeproj"
SCHEME="IAmWorthy"
CONFIG="Release"
ARCHIVE_PATH="build/IAmWorthy.xcarchive"
EXPORT_PATH="build/export"
EXPORT_OPTIONS="ExportOptions.plist"

if [[ "${BUMP_BUILD:-0}" == "1" ]]; then
    NEW_BUILD=$(date +%Y%m%d%H%M)
    echo "▶︎ Bumping CURRENT_PROJECT_VERSION to $NEW_BUILD"
    /usr/libexec/PlistBuddy -c "Set :settings:base:CURRENT_PROJECT_VERSION $NEW_BUILD" project.yml 2>/dev/null || \
        sed -i '' -E "s/CURRENT_PROJECT_VERSION: \".*\"/CURRENT_PROJECT_VERSION: \"$NEW_BUILD\"/" project.yml
    xcodegen generate --spec project.yml
fi

echo "▶︎ Cleaning previous archive"
rm -rf build/IAmWorthy.xcarchive build/export

echo "▶︎ Archiving ($CONFIG)"
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -destination 'generic/platform=iOS' \
    -archivePath "$ARCHIVE_PATH" \
    archive

echo "▶︎ Exporting .ipa"
xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    -exportPath "$EXPORT_PATH" \
    -allowProvisioningUpdates \
    -authenticationKeyID "$ASC_KEY_ID" \
    -authenticationKeyIssuerID "$ASC_ISSUER_ID" \
    -authenticationKeyPath "$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"

IPA_PATH=$(ls "$EXPORT_PATH"/*.ipa | head -n1)
echo "▶︎ Uploading $IPA_PATH to App Store Connect"

xcrun altool --upload-app \
    --type ios \
    --file "$IPA_PATH" \
    --apiKey "$ASC_KEY_ID" \
    --apiIssuer "$ASC_ISSUER_ID"

echo "✅ Uploaded. Check App Store Connect → TestFlight in a few minutes."
