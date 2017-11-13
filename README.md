## Prerequizites

* MacOSX 10.12.6 or above
* Xcode 9 or above
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

##Third-party libraries
All libraries are managed through CocoaPods, the Podfile is available at src/ThoroughbredInsider/Podfile 

##Configuration

Configuration file is located at 'src/ThoroughbredInsider/ThoroughbredInsider/configuration.plist'

* *testEmail* - email for test login
* *testPassword* - password for test login

Mock data is stored in json files at 'src/ThoroughbredInsider/ThoroughbredInsider/Resources/Mock'

##Verification

Check out the video [demo](http://take.ms/zwXEe).

Refer to [forums](https://apps.topcoder.com/forums/?module=ThreadList&forumID=616409&mc=68) and [challenge description](https://www.topcoder.com/challenge-details/30060079/?type=develop).

The screens overview is available at [marvelapp](https://marvelapp.com/jfjdh2g/screen/32358810).

##Addionional notes

1. Mock data contains details & chapters only for the 1st story. You can setup additional chapters in the mock data.
2. There're some caveats with data being overwritten by server - which is mock data - the fetching process has been developed in a way to make integration easier as specified in requirements, not in a way to imitate an actual backend easier
