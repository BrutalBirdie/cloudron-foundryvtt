#!/bin/bash

# Script to generate CloudronVersions.json from git tags
# Requirements: yq, git

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

OUTPUT_FILE="CloudronVersions.json"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Initialize the output JSON structure
cat > "$TEMP_DIR/versions.json" <<EOF
{
  "stable": true,
  "versions": {}
}
EOF

# Get all git tags and sort them
echo "Collecting git tags..."
TAGS=$(git tag --list | sort -V)

# Process each tag
for tag in $TAGS; do
    echo "Processing tag: $tag"
    
    # Check if CloudronManifest.json exists in this tag
    if ! git cat-file -e "$tag:CloudronManifest.json" 2>/dev/null; then
        echo "  Warning: CloudronManifest.json not found in tag $tag, skipping..."
        continue
    fi
    
    # Extract manifest from tag
    MANIFEST=$(git show "$tag:CloudronManifest.json")
    
    # Extract version from manifest
    VERSION=$(echo "$MANIFEST" | yq eval '.version' -)
    
    if [ -z "$VERSION" ] || [ "$VERSION" == "null" ]; then
        echo "  Warning: No version found in manifest for tag $tag, skipping..."
        continue
    fi
    
    # Get commit date in RFC 2822 format (like "Thu, 05 Feb 2026 21:17:03 GMT")
    # Get the commit timestamp and convert to GMT RFC 2822 format
    COMMIT_TIMESTAMP=$(git log -1 --format="%ct" "$tag")
    COMMIT_DATE_GMT=$(TZ=GMT date -d "@$COMMIT_TIMESTAMP" '+%a, %d %b %Y %H:%M:%S GMT' 2>/dev/null || \
                      TZ=GMT date -r "$COMMIT_TIMESTAMP" '+%a, %d %b %Y %H:%M:%S GMT' 2>/dev/null || \
                      echo "Thu, 01 Jan 1970 00:00:00 GMT")
    
    echo "  Found version: $VERSION (commit date: $COMMIT_DATE_GMT)"
    
    # Save manifest to temp file for yq processing
    echo "$MANIFEST" > "$TEMP_DIR/manifest_${VERSION}.json"
    
    # Add version entry using yq
    # We need to merge the manifest object into versions.VERSION.manifest
    yq eval ".versions[\"$VERSION\"] = {
        \"manifest\": load(\"$TEMP_DIR/manifest_${VERSION}.json\"),
        \"creationDate\": \"$COMMIT_DATE_GMT\",
        \"ts\": \"$COMMIT_DATE_GMT\",
        \"publishState\": \"published\"
    }" -i "$TEMP_DIR/versions.json"
done

# Sort versions by semver
# Extract all version keys, sort them, and rebuild the versions object
echo "Sorting versions by semver..."

# Get all version keys and sort them (yq outputs quoted strings, so we need to strip quotes)
VERSION_KEYS=$(yq eval '.versions | keys | .[]' "$TEMP_DIR/versions.json" | tr -d '"' | sort -V)

# Create a new sorted versions object by building it incrementally
cat > "$TEMP_DIR/sorted_versions.json" <<EOF
{
  "versions": {}
}
EOF

for version in $VERSION_KEYS; do
    # Save version data to temp file to avoid shell escaping issues
    yq eval ".versions[\"$version\"]" "$TEMP_DIR/versions.json" -o json > "$TEMP_DIR/version_${version}.json"
    yq eval ".versions[\"$version\"] = load(\"$TEMP_DIR/version_${version}.json\")" -i "$TEMP_DIR/sorted_versions.json"
done

# Rebuild the final JSON with sorted versions
# Create final output with stable first, then versions
cat > "$OUTPUT_FILE" <<EOF
{
  "stable": true,
  "versions": {}
}
EOF

# Copy sorted versions into final output using load to avoid shell escaping issues
yq eval '.versions = load("'$TEMP_DIR'/sorted_versions.json").versions' -i "$OUTPUT_FILE"

# Format the output nicely with stable first
yq eval -P '.' "$OUTPUT_FILE" > "$TEMP_DIR/formatted.json"
mv "$TEMP_DIR/formatted.json" "$OUTPUT_FILE"

echo ""
echo "Successfully generated $OUTPUT_FILE"
echo "Total versions: $(yq eval '.versions | length' "$OUTPUT_FILE")"
