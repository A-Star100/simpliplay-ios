# simpliplay-ios (iOS 4.3-iOS 10.3.3)
*(formerly known as SimpleiOSPlayer)*
## NOTE: Jailbroken device with AppSync Unified is REQUIRED to run the IPA!

**If you want a version compatible with versions of iOS above iOS 10.3.3 use the [SwiftUI version](https://github.com/A-Star100/simpliplay-ios/tree/swiftui)!**
**This will build ONLY with older versions of xcodebuild!!! I had to use a macOS Lion VM just to get this to work!!!**

## Build command
**First, cd into the project directory with the xcodeproj, then execute:**
```shell
xcodebuild -project SimpliPlayLegacyiOS.xcodeproj -target SimpliPlayLegacyiOS -configuration Debug -sdk iphoneos -arch armv7 CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO OTHER_LDFLAGS="-framework MediaPlayer"
Anirudhs-Mac-Pro:SimpliPlayLegacyiOS anirudhsevugan$ xcodebuild -project SimpliPlayLegacyiOS.xcodeproj -target SimpliPlayLegacyiOS -configuration Debug -sdk iphoneos -arch armv7 CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO OTHER_LDFLAGS="-framework MediaPlayer"
```

## Any entitlement-related errors?
**This works on ANY macOS device; no matter how new or old, as long as it has XCode command line tools or the separate `ldid` package installed**.
To fix this, download the `Entitlements.plist` file in this repo, then go ahead and copy it. Next, go into the app bundle (right-click -> Show Package Contents) and then paste the `Entitlements.plist` you copied. Then, in Terminal, go to the app bundle (open Terminal, then type `cd`, then space, then drag the app bundle to Terminal, then press enter).
After this (**this assumes you have the app bundle inside the Payload folder inside of Debug-iphoneos, which is inside Downloads**), use
```shell
ldid -S~/Downloads/Debug-iphoneos/Payload/SimpliPlayLegacyiOS.app/Entitlements.plist ~/Downloads/Debug-iphoneos/Payload/SimpliPlayLegacyiOS.app/SimpliPlayLegacyiOS
```
and you should be ready to go with a clean bundle.

To repack it into an IPA, simply create the Payload folder (if not already there) then right-click and compress it into a ZIP. Once you're done, rename the `.zip` extension to `.ipa` and then you should be ready to install it!
