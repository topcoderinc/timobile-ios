## Prerequizites

* MacOSX 10.12.6 or above
* Xcode 9 or above
* iPhone device/simulator with iOS 11+

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

##Third-party libraries
All libraries are managed through CocoaPods, the Podfile is available at src/ThoroughbredInsider/Podfile 

The new additions in this challenge are
- *KeychainAccess* - keychain wrapper
- *AlamofireImage*, *Alamofire* - networking library
- *RxAlamofire* - reactive wrapper for Alamofire
- *RxPager* - reactive request pager

##Configuration

Configuration file is located at 'src/ThoroughbredInsider/ThoroughbredInsider/configuration.plist'

* *apiBaseUrl* - the base URL for API service

Remaining mock data is stored in json files at 'src/ThoroughbredInsider/ThoroughbredInsider/Resources/Mock'

##Verification

It's important to note that all data changes are persisted through Realm and updated through Realm across the app. No explicit update delegation is allowed in current architecture. No explicit updates of screen model data are allowed (meaning even network requests should NOT yeild direct changes to a screen's content). I've fixed several cases of perpetrations and this rule should now be properly followed in all fully integrated screens.

Check out the video overview for [onboarding & password change](http://take.ms/KfcW5u), [pre story](http://take.ms/4JGlN) and [story, chapters & comments](http://take.ms/vgCxx)
you can also check the old [demo](http://take.ms/zwXEe) to understand that there're some existing differences between iOS & Android versions.

Check that all list requests are appropriately paged.

Refer to [forums](https://apps.topcoder.com/forums/?module=Category&categoryID=40610) and [challenge description](https://www.topcoder.com/challenges/30063029/?type=develop&nocache=true).

The screens desing storyboard is available at [marvelapp](https://marvelapp.com/jfjdh2g/screen/32358810).
