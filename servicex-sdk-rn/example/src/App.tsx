import * as React from 'react';
import { useEffect, useState } from 'react';
import Spinner from 'react-native-loading-spinner-overlay';

import {
  StyleSheet,
  View,
  Button,
  Text,
  FlatList,
  Image,
  TouchableOpacity,
  TextInput,
} from 'react-native';
import ServiceXSdk, { OfferData, UserPayload } from 'servicex-sdk-rn';

const API_KEY =
  '4nN5UifKTRxR1At4syeBHM6e4p0cFOdoqsuUKOIgSYBEJRa8UpGprqorfyWFgdVk';
const ENV = 'SANDBOX';
const PUSH_CLAIM_URL = 'https://sandbox-demo-api.credify.dev/tiki/push-claims';
const DEMO_USER_URL = 'https://sandbox-demo-api.credify.dev/tiki/demo-user';
const MARKET_NAME = 'tiki';

export default function App() {
  const [user, setUser] = useState<any>(null);
  const [idText, onChangeText] = useState<string>('');
  const [offersData, setOffers] = useState<OfferData[]>([]);
  const [isLoading, showLoading] = useState<boolean>(false);

  useEffect(() => {
    ServiceXSdk.initialize(API_KEY, ENV, MARKET_NAME);
    getDemoUsers();
  }, []);

  async function offerListHandler() {
    if (!user) {
      return;
    }
    ServiceXSdk.clearCache();
    showLoading(true);
    try {
      const payload: UserPayload = {
        phone_number: user.phoneNumber,
        country_code: user.phoneCountryCode,
        local_id: user.id,
        credify_id: user.credifyId,
      };
      const res = await ServiceXSdk.getOffers(payload);
      const credifyId = res.credifyId;
      const offers = res.offerList;
      setOffers(offers);
      console.log({ res });
      console.log({ credifyId });
      console.log({ offers });
    } catch (error) {
      console.log({ error });
    }

    showLoading(false);
  }

  async function showReferal() {
    ServiceXSdk.showReferralResult();
  }

  async function getDemoUsers() {
    setOffers([]);
    showLoading(true);
    try {
      const res = await fetch(`${DEMO_USER_URL}?id=${idText}`);
      const _user = await res.json();
      console.log({ _user });
      setUser(_user);
      const userProfile = {
        id: _user.id,
        first_name: _user.phoneNumber,
        last_name: _user.lastName,
        middle_name: _user.middleName,
        name: _user.name,
        phone_number: _user.phoneNumber,
        country_code: _user.phoneCountryCode,
        email: _user.email,
      };
      console.log({ userProfile });
      onChangeText(_user.id);
      ServiceXSdk.setUserProfile(userProfile);
      ServiceXSdk.setCredifyId(_user.credifyId);
    } catch (error) {
      console.log(error);
    }
    showLoading(false);
  }

  function showOfferDetail(offerId: string) {
    ServiceXSdk.showOfferDetail(
      offerId,
      async (localId: string, credifyId: string) => {
        try {
          const res = await pushClaim(localId, credifyId);
          console.log({ res });
          ServiceXSdk.setPushClaimRequestStatus(true);
        } catch (error) {
          ServiceXSdk.setPushClaimRequestStatus(false);
        }
      }
    );
  }

  async function pushClaim(localId: string, credifyId: string) {
    const body = {
      id: localId,
      credify_id: credifyId,
    };
    try {
      const res = await fetch(PUSH_CLAIM_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
      });
      return res.json();
    } catch (error) {
      throw error;
    }
  }

  const renderItem = ({ item }: { item: OfferData }) => {
    return (
      <TouchableOpacity
        onPress={() => {
          console.log({ item });
          showOfferDetail(item.id!!);
        }}
      >
        <View
          style={{ flexDirection: 'row', alignItems: 'center', marginTop: 10 }}
        >
          <Image
            style={{ width: 50, height: 50, marginRight: 5 }}
            source={{ uri: item.campaign?.thumbnailUrl }}
          />
          <Text>{item.campaign?.description}</Text>
        </View>
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.container}>
      <View style={{ marginTop: 10 }} />
      <Button onPress={getDemoUsers} title="Get Demo user" color="#841584" />

      <View style={{ marginTop: 10 }} />
      <Button
        onPress={offerListHandler}
        title="Get offer list"
        color="#841584"
      />

      <View style={{ marginTop: 10 }} />
      <Button onPress={showReferal} title="Show referal " color="#841584" />
      <Text>Current user ID (Empty the input to get random user)</Text>
      <TextInput
        style={{ borderWidth: 1, borderColor: 'grey' }}
        onChangeText={onChangeText}
        value={idText.toString()}
      />
      <FlatList
        data={offersData}
        renderItem={renderItem}
        keyExtractor={(item) => item.id!!}
      />
      <Spinner visible={isLoading} textContent={'Loading...'} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
