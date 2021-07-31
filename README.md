# servicex-sdk-rn

A serviceX sdk for react-native

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

//** And it credifyId if have
ServiceXSdk.setCredifyId(credifyId)

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

//** If you want to show the referral result for the current user
ServiceXSdk.showReferralResult()
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
