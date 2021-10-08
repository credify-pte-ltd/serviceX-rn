# Example app for servicex-rn

A basic app to demo how to use the `servicex-rn` SDK to get offers, redeem the offer and show the passport for user to login to see the offers's status

## Installation

```sh
yarn
```

Run example app in Android:

```sh
yarn android
```

Run example app in iOS

```sh
yarn ios
```

## Release build issues:

### Android

If you want to make a release build, you need to change the `index.js` to `index.tsx` The android bundler script has issues with bundling the js file in the typescript project

### iOS:

if you see the issue:

```
... FinalSDK does not contain bitcode. You must rebuild it with bitcode enabled (Xcode setting ENABLE_BITCODE)...
```

Then please disable bitcode from your pods. The fast way to do it is go to your Pods project in XCode and set Enable Bitcode to Yes first then set it to No to disable bitcode complie for all pods.

When you want to archive the IPA for distributing the app but cannot export the IPA after finishing archive due to invalid file format for the archive file then please clean the build and set the build to relese mode by go to Product -> Schema -> Edit Schema -> Set build configuration to Release then archive again
