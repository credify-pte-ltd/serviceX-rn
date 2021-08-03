# servicex-sdk-rn

A serviceX sdk for react-native (Support RN 0.59.x and above)

## Installation

```sh
yarn add servicex-sdk-rn
```

or

```sh
npm install servicex-sdk-rn
```

Then link the native module if your project does not support auto link (RN version < 0.60)

```sh
react-native link
```

In your iOS pod file, add the pod command below to your target:

```swift
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
  end
```

## Usage

Please refer to the example project inside the SDK to see how it work with our demo server

```js
import ServiceXSdk from "servicex-sdk-rn"

//** Initialize project
ServiceXSdk.initialize(API_KEY, ENV, MARKET_NAME)

// Clear old user in the SDK
ServiceXSdk.clearCache()

//** You need to tell SDK what is current user profile
ServiceXSdk.setUserProfile(userProfile)

//** Show offers list
const res = await ServiceXSdk.getOffers(payload)

//** Show offer detail
ServiceXSdk.showOfferDetail(
  offerId,
  async (localId: string, credifyId: string) => {
    //** You need to add your push claim request in this callback and tell the SDK for the result
    try {
      const res = await pushClaim(localId, credifyId)
      console.log({ res })
      ServiceXSdk.setPushClaimRequestStatus(true)
    } catch (error) {
      ServiceXSdk.setPushClaimRequestStatus(false)
    }
  }
)
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
