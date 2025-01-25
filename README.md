# simpliplay-ios
*(formerly known as SimpleiOSPlayer)*

View the demo [here!](https://youtu.be/KazDMpwsr-4)

Looking for the **Android** version? Check out [simpliplay-android](https://github.com/A-Star100/simpliplay-android)!

## Get Started
Due to Apple restrictions, I can't currently build IPAs (iOS App Packages) right now that are installable on a user's device, and even if I could I would have to pay Apple $100 a year and join the Developer program. Android is so much more open. However, I can guide you on compiling for yourself.

### Install XCode
After creating an Apple account (if you haven't) XCode is the next step. It is ***required*** for compiling apps, no questions asked. On your Mac (or if you're emulating on Windows, your emulator), open the **Mac App Store** and install XCode on your computer. This can take a while, and you'll need at least **40 GB** of free space.

### Open XCode and import the source code
Once XCode is installed (and all of the tools that come with it, like the iOS Simulator), you'll need to import the source code. You can use `git clone`, download a ZIP of the source code from GitHub, or use XCode's **built-in** repository cloning functionality by entering the URL and cloning the repository. If you used XCode's built in repository cloning, skip the next step.

#### If you used `git clone` or GitHub
Simply click *Open New Project* and click on the folder where the source code is. You should now see that the project has loaded. From here, you can modify the source code and add new features. Once you've added features, you can do a pull request (which would be appreciated since I'm just starting to develop iOS apps, but you don't have to).

### Distributing the app
You'll need to set up your Apple Developer account. Sign in to the **Apple Developer Portal** and enter your Apple account's credentials. Then you can add a mobileprovision profile to allow the app to be installed and used on your Apple device for up to 7 days, or if you're open to paying $100 a year, you can enroll for the Apple Developer Program, and distribute to the App Store, and even distribute the app as an Ad Hoc (IPA) to other users (however IPA files require Developer Mode to be enabled to the user's device even if they were signed starting from iOS 16).

Hope you like the app!
