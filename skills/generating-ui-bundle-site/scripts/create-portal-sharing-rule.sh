#!/usr/bin/env bash
# Scaffolds a portal user SharingRules metadata file for an Experience Site.
# Supports criteria-based and owner-based rules for authenticated portal/community users.
#
# Usage:
#   ./create-portal-sharing-rule.sh <ObjectAPIName> <RuleType> [OutputDir]
#
# Arguments:
#   ObjectAPIName  Salesforce API name of the object (e.g. Account, Case, My_Object__c)
#   RuleType       One of: criteria | owner
#   OutputDir      Optional. Defaults to force-app/main/default/sharingRules
#
# Examples:
#   ./create-portal-sharing-rule.sh Account criteria
#   ./create-portal-sharing-rule.sh Case owner ./force-app/main/default/sharingRules

set -euo pipefail

OBJECT="${1:-}"
RULE_TYPE="${2:-}"
OUTPUT_DIR="${3:-force-app/main/default/sharingRules}"

if [[ -z "$OBJECT" || -z "$RULE_TYPE" ]]; then
  echo "Usage: $0 <ObjectAPIName> <RuleType: criteria|owner> [OutputDir]"
  exit 1
fi

case "$RULE_TYPE" in
  criteria|owner) ;;
  *)
    echo "Error: RuleType must be one of: criteria, owner"
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../references/sharing-portal-${RULE_TYPE}-rule.xml"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Error: template not found at $TEMPLATE"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

FILE="$OUTPUT_DIR/${OBJECT}.sharingRules-meta.xml"

if [[ -f "$FILE" ]]; then
  echo "File already exists: $FILE"
  echo "Edit it directly to add another rule element rather than overwriting."
  exit 0
fi

sed -e "s/\${Object}/${OBJECT}/g" "$TEMPLATE" > "$FILE"

echo "Created: $FILE — replace the TODO placeholders with real field/value criteria or ownership targets."
