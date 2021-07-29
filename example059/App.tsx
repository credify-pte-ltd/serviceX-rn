/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, { Component } from "react"
import { Button, Platform, StyleSheet, Text, View } from "react-native"

const App = () => {
  console.log("Hello APP!!!!")
  function offerListHandler() {}
  function showOfferDetail() {}

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
