# SPEC: MIGRATE CARD-MIND TO FASTLANE MATCH + PRE-RELEASE VALIDATION

Repository:
NguyenMinhDuc163/Card-Mind

Bundle ID:
com.nguyenduc.cardMind

Team ID:
Q236Z72BGN

Signing repo:
https://github.com/NguyenMinhDuc163/apple-signing.git

==================================================
1. GOAL
==================================================

Replace manual iOS signing:

IOS_DISTRIBUTION_CERTIFICATE_P12_BASE64
IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
IOS_APPSTORE_PROVISIONING_PROFILE_BASE64

with Fastlane Match readonly.

Also add pre-release validation before version bump.

Do not redesign Android/mobile release architecture.

==================================================
2. EXISTING SIGNING ASSET
==================================================

Use existing:

profiles/appstore/
AppStore_com.nguyenduc.cardMind.mobileprovision

and existing Distribution certificate in apple-signing.

Never:
- modify apple-signing
- regenerate certificate/profile
- revoke anything
- match nuke
- readonly:false

==================================================
3. FILES
==================================================

Add:

ios/fastlane/Matchfile
.github/workflows/reusable-validate-project.yml

Modify:

ios/fastlane/Fastfile
ios/fastlane/Appfile
ios/Runner.xcodeproj/project.pbxproj
.github/workflows/reusable-ios-testflight.yml
.github/workflows/mobile-store-release.yml

Update stale signing docs if present.

==================================================
4. MATCHFILE
==================================================

git_url(ENV.fetch("MATCH_GIT_URL"))
storage_mode("git")
git_branch("main")

app_identifier([
  "com.nguyenduc.cardMind"
])

type("appstore")

team_id(ENV["IOS_TEAM_ID"]) unless ENV["IOS_TEAM_ID"].to_s.strip.empty?

==================================================
5. FASTFILE
==================================================

Keep existing build logic.

lane :beta order:

setup_ci

api_key = app_store_connect_api_key(...)

match(
  type: "appstore",
  platform: "ios",
  app_identifier: APP_IDENTIFIER,
  readonly: true,
  api_key: api_key
)

Get:

SharedValues::MATCH_PROVISIONING_PROFILE_MAPPING

Require mapping for:

com.nguyenduc.cardMind

Set:

ENV["IOS_PROVISIONING_PROFILE_NAME"] = matched_profile_name

Then:

build
validate archive
upload_to_testflight

==================================================
6. REMOVE OLD MANUAL SIGNING
==================================================

Remove workflow secrets:

IOS_DISTRIBUTION_CERTIFICATE_P12_BASE64
IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
IOS_APPSTORE_PROVISIONING_PROFILE_BASE64

Remove:
- P12 Base64 decode
- mobileprovision decode
- manual keychain creation
- security import
- manual profile install

Use setup_ci + Match only.

==================================================
7. REQUIRED SECRETS
==================================================

Keep:

APP_STORE_CONNECT_KEY_ID
APP_STORE_CONNECT_ISSUER_ID
APP_STORE_CONNECT_API_KEY_P8

Add:

IOS_TEAM_ID
MATCH_GIT_URL
MATCH_PASSWORD
MATCH_GIT_BASIC_AUTHORIZATION

Expected:

IOS_TEAM_ID=Q236Z72BGN

MATCH_GIT_URL=
https://github.com/NguyenMinhDuc163/apple-signing.git

Reuse the same proven Match credentials used by previous projects.

Do NOT add ENV_FILE_CONTENTS unless repository inspection proves it is
actually required.

==================================================
8. APPFILE
==================================================

Remove:

apple_id("ngminhduc1603@icloud.com")

Keep:

app_identifier("com.nguyenduc.cardMind")
team_id("Q236Z72BGN")

==================================================
9. FIX VERSION PROPAGATION
==================================================

pubspec.yaml must be source of truth.

Main Runner Debug/Profile/Release must use:

MARKETING_VERSION = "$(FLUTTER_BUILD_NAME)";
CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";

Do not keep hardcoded Xcode versions.

Do not blindly modify RunnerTests.

==================================================
10. ARCHIVE PATH
==================================================

Use ONE absolute path for build and validation:

<repo>/build/ios/archive/Runner.xcarchive

Derive from:

GITHUB_WORKSPACE

or repository root.

Never hardcode:

/Users/runner/work/Card-Mind/Card-Mind

Use the same path in build_app and archive validation.

==================================================
11. VALIDATE ARCHIVE BEFORE TESTFLIGHT
==================================================

After build_app inspect:

Runner.xcarchive/
Products/Applications/Runner.app/Info.plist

Require:

CFBundleShortVersionString == pubspec version
CFBundleVersion == pubspec build number

Fail before upload if mismatch.

Do not trust IPA filename alone.

==================================================
12. PRE-RELEASE VALIDATION
==================================================

Create:

.github/workflows/reusable-validate-project.yml

Run on Ubuntu BEFORE bump_version.

Validate:

APP_STORE_CONNECT_KEY_ID
APP_STORE_CONNECT_ISSUER_ID
APP_STORE_CONNECT_API_KEY_P8
IOS_TEAM_ID
MATCH_GIT_URL
MATCH_PASSWORD
MATCH_GIT_BASIC_AUTHORIZATION

Checks:

- all secrets present
- IOS_TEAM_ID == Q236Z72BGN
- MATCH_GIT_URL correct
- P8 PEM format valid
- apple-signing readable
- MATCH_PASSWORD decrypt succeeds
- profile exists for com.nguyenduc.cardMind
- profile Team ID == Q236Z72BGN
- App Store Connect authentication succeeds

Validation must be read-only.

Do not upload or modify anything.

Do not print secrets.

==================================================
13. RELEASE ORDER
==================================================

mobile-store-release.yml:

validate_project
      ↓
bump_version
      ↓
build_testflight / build_google_play

If validation fails:

- no version bump
- no macOS runner
- no store build

Android behavior remains unchanged after validation succeeds.

==================================================
14. PREVIOUS-MIGRATION LESSONS
==================================================

Do NOT:

- create custom Match keychain paths
- hardcode fastlane_tmp_keychain
- hardcode GitHub runner repository paths
- trust IPA filename for version
- regenerate MATCH_PASSWORD
- use raw PAT instead of Base64 Basic auth
- assume GITHUB_TOKEN can read private apple-signing
- update Fastlane/Gemfile.lock unnecessarily

==================================================
15. OLD SECRETS
==================================================

Agent must NOT delete GitHub secrets.

Only after a real TestFlight build succeeds, user may delete:

IOS_DISTRIBUTION_CERTIFICATE_P12_BASE64
IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
IOS_APPSTORE_PROVISIONING_PROFILE_BASE64

==================================================
16. ACCEPTANCE
==================================================

[ ] Matchfile added
[ ] setup_ci before Match
[ ] Match appstore readonly
[ ] cardMind profile mapping validated
[ ] manual signing removed
[ ] personal Apple ID removed
[ ] Runner uses FLUTTER_BUILD_NAME
[ ] Runner uses FLUTTER_BUILD_NUMBER
[ ] shared absolute archive path
[ ] archive version checked before upload
[ ] validation runs before bump_version
[ ] Match repo/decrypt/profile validated
[ ] ASC auth validated
[ ] Android unchanged
[ ] apple-signing unchanged
[ ] no secrets printed
[ ] no TestFlight triggered unless explicitly requested

Final report:
- changed files
- validation result
- Match configuration
- versioning fix
- old secrets no longer referenced
- confirm apple-signing not modified