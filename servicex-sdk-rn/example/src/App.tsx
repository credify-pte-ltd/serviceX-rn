import * as React from 'react';

import { StyleSheet, View, Button } from 'react-native';
import ServiceXSdk from 'servicex-sdk-rn';

export default function App() {
  async function offerListHandler() {
    try {
      const offers = await ServiceXSdk.getOffers('1');
      console.log({ offers });
    } catch (error) {
      console.log({ error });
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
        onPress={() => ServiceXSdk.showOfferDetail('2')}
        title="Show offer detail"
        color="#841584"
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
