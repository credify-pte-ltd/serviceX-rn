/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, { Component } from "react"
import { Button, Platform, StyleSheet, Text, View } from "react-native"
import { ToastExample, CredifySdk } from "./NativeModuleApi"

const App = () => {
  console.log("Hello APP!!!!")
  return (
    <View style={styles.container}>
      <Button
        onPress={() =>
          ToastExample.show(
            "This is Toast from native module",
            ToastExample.SHORT
          )
        }
        title="Show Toast"
        color="#841584"
      />
      <View style={{ marginTop: 10 }} />
      <Button
        onPress={() =>
          CredifySdk.getOfferList(
            "1",
            (model: any) => {
              console.log({ model })
              console.log({ jsonObject: JSON.parse(model) })
            },
            (error: any) => {
              console.log({ error })
            }
          )
        }
        title="Get offer list"
        color="#841584"
      />

      <View style={{ marginTop: 10 }} />
      <Button
        onPress={() => CredifySdk.showOfferDetail("1")}
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
