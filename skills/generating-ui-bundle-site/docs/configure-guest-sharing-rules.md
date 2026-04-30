# Guest User Sharing Rules (Public Sites Only)

**Use when** the user wants to share object records with unauthenticated visitors of an Experience Site (guest users), or mentions a username containing "Guest User" or "Site Guest User" (e.g. `ZenLease Site Guest User`).

---

## Step 1: Fetch Existing Sharing Rules from the Org

Always attempt to retrieve existing rules before creating new ones. Retrieved files land at `force-app/main/default/sharingRules/`.

### Retrieve rules for a specific object
```bash
sf project retrieve start \
  --metadata "SharingRules:{ObjectAPIName}" \
  --target-org {usernameOrAlias}
```

### Retrieve rules for multiple objects
```bash
sf project retrieve start \
  --metadata "SharingRules:{ObjectAPIName}" "SharingRules:{OtherObjectAPIName}" \
  --target-org {usernameOrAlias}
```

### Retrieve all sharing rules in the org
```bash
sf project retrieve start \
  --metadata "SharingRules" \
  --target-org {usernameOrAlias}
```

### Locate and inspect what was retrieved
```bash
find force-app/main/default/sharingRules -name "*.sharingRules-meta.xml" | sort
cat force-app/main/default/sharingRules/{ObjectAPIName}.sharingRules-meta.xml
```

---

## Step 2: Resolve the Guest User Identity

The `<guestUser>` value must be the **CommunityNickname** of the site's guest user — not the URL path prefix.

- If the user provides a username like `ZenLease Site Guest User`, use it directly as the `<guestUser>` value.
- If a user ID is provided (e.g. `005AAC00003f8EP`), query the org first:

```bash
sf data query \
  --query "SELECT CommunityNickname FROM User WHERE Id = '005AAC00003f8EP'" \
  --target-org {usernameOrAlias}
```

---

## Step 3: Create New Rules (When None Exist)

If retrieval returns no file for the object, use the script to scaffold one:

```bash
./skills/generating-ui-bundle-site/scripts/create-guest-sharing-rule.sh \
  {ObjectAPIName} {SiteGuestUserCommunityNickname} force-app/main/default/sharingRules
```

Then replace the TODO placeholders before deploying.

---

## Step 4: Metadata Reference

**File location:**
```
force-app/main/default/sharingRules/{ObjectAPIName}.sharingRules-meta.xml
```

One file per object. All rules for a given object live in one file.

See reference: [references/sharing-guest-rule.xml](../references/sharing-guest-rule.xml)

### Critical Requirements

- **`<guestUser>`**: Must be the CommunityNickname of the site guest user — not a role, group, or URL prefix.
- **`<includeHVUOwnedRecords>`**: Required. Set to `false` unless records owned by high-volume site users must be included.
- **`<accessLevel>`**: Must be `Read`. Guest users cannot receive `Edit` access.
- **`<criteriaItems>`**: Required to scope which records are exposed.
- **One file per object**: Do not create separate files for additional rules on the same object — add them as additional `<sharingGuestRules>` elements.

### Common Mistakes

- Using `<role>` or `<group>` instead of `<guestUser>` in `<sharedTo>`
- Omitting `<includeHVUOwnedRecords>`
- Using `<includeRecordsOwnedByAll>` (that is for `sharingCriteriaRules`, not guest rules)
- Using the site URL path prefix instead of the CommunityNickname

---

## Step 5: Deploy

### Validate before deploying
```bash
sf project deploy start \
  --metadata "SharingRules:{ObjectAPIName}" \
  --dry-run \
  --target-org {usernameOrAlias}
```

### Deploy
```bash
sf project deploy start \
  --metadata "SharingRules:{ObjectAPIName}" \
  --target-org {usernameOrAlias}
```
