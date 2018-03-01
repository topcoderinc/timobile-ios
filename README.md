
## Prerequisites

* MacOSX 10.12.6 or above
* Xcode 9.2 or above
* iPhone device/simulator with iOS 10+

## Organization of Submission
* src – this directory contains the source code
* docs – this directory contains the documents for this application, including this deployment guide

## Deployment
Open the 'src/ThoroughbredInsider' in submission folder.
Pods directory should be ready to use. However, in future 3rd party libraries must be pulled using the following command runned from 'src/ThoroughbredInsider' directory:
`$ pod install`

You will need to configure the app as described in Configuration section.

To build and run the app in a simulator/device you will need to do the following:

1. Open 'src/ThoroughbredInsider/ThoroughbredInsider.xcworkspace' in Xcode
2. Select ThoroughbredInsider scheme from the top left dropdown list.
3. Select a real device (when connected) or a simulator from the top left dropdown list.
4. Click menu Product -> Run (Cmd+R)
5. Follow the verification steps described in verification section

Make sure you deleted previous version of the app or app from different submission if it was present on the target device/simulator.

If you want to use local backend server, then you need to deploy it (see reference to [backend repository in the forum](https://apps.topcoder.com/forums/?module=Thread&threadID=911414&start=0)) and configure base URL in `Configuration.plist` (see "Configuration" section).

## Third-party libraries
All libraries are managed through CocoaPods, the Podfile is available at src/ThoroughbredInsider/Podfile

**KeychainAccess** framework is additionally added to the project - https://github.com/kishikawakatsumi/KeychainAccess
Version 3.1.0. It's used to store access token.

## Configuration

Configuration file is located at 'src/ThoroughbredInsider/ThoroughbredInsider/Configuration.plist'

* *testEmail* - email for test login
* *testPassword* - password for test login
* *apiBaseUrl* - base URL for API

Mock data is stored in JSON files at 'src/ThoroughbredInsider/ThoroughbredInsider/Resources/Mock'

## Verification

Check out the video [demo](https://youtu.be/1l_altb1zWg).

Refer to [forums](https://apps.topcoder.com/forums/?module=Category&categoryID=40610) and [challenge description](https://www.topcoder.com/challenges/30063029/?type=develop&tab=details).

The screens overview is available at [marvelapp](https://marvelapp.com/jfjdh2g/screen/32358810).

You can use ready to use accounts to Sign In (provided in [the forum](https://apps.topcoder.com/forums/?module=Thread&threadID=911415&start=0)).

## Notes

- A lot of UI issues in iPhone 5s. Because new screens were added (Sign Up, Forgot Password and Change Password), then make sure there is no UI issues for new screens. UI issues on existing screens are our of scope.
- There was no auto focus on racetracks  in map. Fixed.
- States and Racetracks search fixed in "PreStory" screens.
- The selected state in PreStory is used to filter Racetracks on the second PreStory screen (watch the video).
- The first selected racetrack in PreStory screen is used for initial filtering of the stories. There is inconsistency in PreStory design UI and API - API supports only one racetrack ID as a filter. The racetrack filter on Stories List allows to select only one racetrack which matches the API. However, PreStory allows to select multiple racetracks. Unfortunately, API does not support it. To turn on single selection on PreStory use `OPTION_PRESTORY_SINGLE_RACETRACK_SELECTION = true` in the code. By default it’s set to false to follow initial behavior.
- The simulated location is always reset in Xcode to “Don’t Simulate Location”. So, you need to select simulated location every time you relaunch the app (watch the video on how to turn it on by click a button above Xcode console).
- Unused JSON files are removed.
- Verify the flow when user choose "Deny" for Location Services: 1. Delete the app and relaunch. 2. Choose "Deny". 3. Note that "N/A" is shown for the distance to all racetrack. 4. Turn on Location Services for the app in Settings app (Privacy -> Location Services -> ThoroughbredInsider -> While Using the App". 5. Open the app and check that distances are updated. Also verify that the distance is shown on the map (when racetrack is selected).

There are lot of UI issues. Some of them are fixed (see above) and some of them not (out of scope of this challenge). Also there are differences in Android app and iOS app implementations:
- "Read More" button on "Story Details" screen works differently on Android.
- "Summary" section height is not dynamic in iOS app (UI issue; out of scope).
- It seems that progress should not be shown for Admin user (shown in both - Android and iOS apps).
- Progress checkmark was missing (shown on green circle) - fixed.
- Input field in Comments was disappear after posting a comment - fixed.
- Android app shows Story summary for Additional Task. This is incorrect, because response contains “description” for Additional Task. However, `OPTION_SHOW_SUMMARY_IN_ADDITIONAL_TASK` added in the code - if set to `true`, then shows summary as Android app does. It’s `false` by default.
- A few more options added in the code to switch between different behaviors. Search for "let OPTION_" in the code and check the documentation there.
