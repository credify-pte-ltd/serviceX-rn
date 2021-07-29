/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, { Component } from "react"
import { Button, Platform, StyleSheet, Text, View } from "react-native"
import { ToastExample, CredifySdk, CredifySdkManager } from "./NativeModuleApi"

const App = () => {
  console.log("Hello APP!!!!")
  function offerListHandler() {
    try {
      const model = CredifySdk.getOfferList("1")
      console.log({ model })
      console.log({ jsonObject: JSON.parse(model) })
    } catch (error) {
      console.log(error)
    }
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
        onPress={() => CredifySdk.showOfferDetail("1")}
        title="Show offer detail"
        color="#841584"
      />

      <View style={{ marginTop: 10 }} />
      <Button
        onPress={() => CredifySdkManager.addEvent("Credify Danh Event")}
        title="Show event added ios"
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
