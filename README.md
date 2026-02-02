# simpliplay-ios (iOS 4.3-iOS 10.3.3)
*(formerly known as SimpleiOSPlayer)*

**If you want a version compatible with versions of iOS above iOS 10.3.3 use the SwiftUI version!**
**This will build ONLY with older versions of xcodebuild!!! I had to use a macOS Lion VM just to get this to work!!!**

## Build command
**First, cd into the project directory with the xcodeproj, then execute:**
```shell
xcodebuild -project SimpliPlayLegacyiOS.xcodeproj -target SimpliPlayLegacyiOS -configuration Debug -sdk iphoneos -arch armv7 CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO OTHER_LDFLAGS="-framework MediaPlayer"
Anirudhs-Mac-Pro:SimpliPlayLegacyiOS anirudhsevugan$ xcodebuild -project SimpliPlayLegacyiOS.xcodeproj -target SimpliPlayLegacyiOS -configuration Debug -sdk iphoneos -arch armv7 CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO OTHER_LDFLAGS="-framework MediaPlayer"
```
