# Portal User Sharing Rules (Authenticated Site Users)

**Use when** the user wants to share object records with authenticated visitors of an Experience Site — portal users, Customer Community users, or any profile containing "Portal User" or "Customer Community User".

Portal users use **Criteria** and **Owner** sharing rules. They do not use `sharingGuestRules`.

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

## Step 2: Choose Rule Type

| Rule Type | When to Use |
|-----------|-------------|
| **Criteria-based** (`sharingCriteriaRules`) | Share records where a field value matches a filter |
| **Owner-based** (`sharingOwnerRules`) | Share records owned by one role/group with another |

---

## Step 3: Create New Rules (When None Exist)

If retrieval returns no file for the object, use the script to scaffold one:

```bash
# Criteria-based rule
./skills/generating-ui-bundle-site/scripts/create-portal-sharing-rule.sh \
  {ObjectAPIName} criteria force-app/main/default/sharingRules

# Owner-based rule
./skills/generating-ui-bundle-site/scripts/create-portal-sharing-rule.sh \
  {ObjectAPIName} owner force-app/main/default/sharingRules
```

Then replace the TODO placeholders before deploying.

---

## Step 4: Metadata Reference

**File location:**
```
force-app/main/default/sharingRules/{ObjectAPIName}.sharingRules-meta.xml
```

One file per object. All rules for a given object live in one file.

### Criteria-Based Sharing Rule

Use when sharing records based on field values.

See reference: [references/sharing-portal-criteria-rule.xml](../references/sharing-portal-criteria-rule.xml)

### Owner-Based Sharing Rule

Use when sharing records based on record ownership (role, group, or all portal users).

See reference: [references/sharing-portal-owner-rule.xml](../references/sharing-portal-owner-rule.xml)

### Critical Requirements

- **`<sharedTo>`**: Must use `<allCustomerPortalUsers></allCustomerPortalUsers>` for portal users. Do not use `<role>` or `<group>`.
- **`<includeRecordsOwnedByAll>`**: Required on `sharingCriteriaRules` only. Set to `false` unless records owned by all users should be included. Do not add this field to `sharingOwnerRules`.
- **`<accessLevel>`**: `Read` or `Edit`.
- **One file per object**: Add additional rules as new elements in the same file — do not create separate files.

### Common Mistakes

- Using `<role>` or `<group>` instead of `<allCustomerPortalUsers>` in `<sharedTo>`
- Adding `<includeRecordsOwnedByAll>` to an owner rule (criteria rules only)
- Using `<includeHVUOwnedRecords>` (that is for `sharingGuestRules`)

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
