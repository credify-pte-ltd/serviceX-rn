/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React from "react"
import { Button, StyleSheet, Text, View } from "react-native"
import ServiceXSdk from "servicex-sdk-rn"

const App = () => {
  console.log("Hello APP!!!!")
  async function offerListHandler() {
    try {
      const offers = await ServiceXSdk.getOffers("2")
      console.log({ offers })
    } catch (error) {
      console.log({ error })
    }
  }

  function showOfferDetail() {
    ServiceXSdk.showOfferDetail("2")
  }

  return (
    <View style={styles.container}>
      <Button
        onPress={offerListHandler}
        title="Get offer list"
        color="#841584"
      />

      <View style={{ marginTop: 10 }} />
      <Button
        onPress={showOfferDetail}
        title="Show offer detail"
        color="#841584"
      />
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#F5FCFF",
  },
})

export default App
