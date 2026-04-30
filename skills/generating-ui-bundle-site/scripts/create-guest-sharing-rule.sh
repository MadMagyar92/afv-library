#!/usr/bin/env bash
# Scaffolds a sharingGuestRules metadata file for an Experience Site public (guest) user.
#
# Usage:
#   ./create-guest-sharing-rule.sh <ObjectAPIName> <GuestUserCommunityNickname> [OutputDir]
#
# Arguments:
#   ObjectAPIName              Salesforce API name of the object (e.g. Account, Case, My_Object__c)
#   GuestUserCommunityNickname CommunityNickname of the site guest user (NOT the URL path prefix).
#                              Query it with:
#                                sf data query \
#                                  --query "SELECT CommunityNickname FROM User WHERE Name = 'MySite Guest User'" \
#                                  --target-org <alias>
#   OutputDir                  Optional. Defaults to force-app/main/default/sharingRules
#
# Examples:
#   ./create-guest-sharing-rule.sh Account ZenLeaseSiteGuestUser
#   ./create-guest-sharing-rule.sh Case ZenLeaseSiteGuestUser ./force-app/main/default/sharingRules

set -euo pipefail

OBJECT="${1:-}"
GUEST_NICKNAME="${2:-}"
OUTPUT_DIR="${3:-force-app/main/default/sharingRules}"

if [[ -z "$OBJECT" || -z "$GUEST_NICKNAME" ]]; then
  echo "Usage: $0 <ObjectAPIName> <GuestUserCommunityNickname> [OutputDir]"
  echo ""
  echo "To find the CommunityNickname, run:"
  echo "  sf data query --query \"SELECT CommunityNickname FROM User WHERE Name LIKE '%Guest User%'\" --target-org <alias>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../references/sharing-guest-rule.xml"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Error: template not found at $TEMPLATE"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

FILE="$OUTPUT_DIR/${OBJECT}.sharingRules-meta.xml"

if [[ -f "$FILE" ]]; then
  echo "File already exists: $FILE"
  echo "Edit it directly to add another <sharingGuestRules> element rather than overwriting."
  exit 0
fi

sed \
  -e "s/\${Object}/${OBJECT}/g" \
  -e "s/\${GuestName}/${GUEST_NICKNAME}/g" \
  "$TEMPLATE" > "$FILE"

echo "Created: $FILE — replace the TODO criteriaItems filter with real field/value criteria."
