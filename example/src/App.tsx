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
  SafeAreaView,
} from 'react-native';
import serviceX, { OfferData, ProductType, RedemptionStatus } from 'servicex-rn';

const API_KEY =
  '7kx6vx9p9gZmqrtvHjRTOiSXMkAfZB3s5u3yjLehQHQCtjWrjAk9XlQHR2IOqpuR';
const ENV = 'SANDBOX';
const PUSH_CLAIM_URL =
  'https://sandbox-demo-api.credify.dev/housecare/push-claims';
const DEMO_USER_URL =
  'https://sandbox-demo-api.credify.dev/housecare/demo-user';
const MARKET_NAME = 'housecare';
const MARKET_ID = '039f059a-3d58-4592-b359-834f5fe9a442';

export default function App() {
  const [user, setUser] = useState<any>(null);
  const [idText, onChangeText] = useState<string>('');
  const [offersData, setOffers] = useState<OfferData[]>([]);
  const [isLoading, showLoading] = useState<boolean>(false);

  useEffect(() => {
    const customTheme = {
      primaryBrandyStart: '#fc030b',
      primaryBrandyEnd: '#0066ff',
    };

    serviceX.initialize(API_KEY, ENV, MARKET_NAME, customTheme);
    getDemoUsers();
  }, []);

  async function offerListHandler() {
    if (!user) {
      return;
    }
    showLoading(true);
    try {
      const res = await serviceX.getOffers();
      const offers = res.offerList;
      setOffers(offers);
    } catch (error) {
      console.log({ error });
    }

    showLoading(false);
  }

  function showPassportHandler() {
    serviceX.showPassport(
      async (localId: string, credifyId: string) => {
        try {
          const res = await pushClaim(localId, credifyId);
          console.log({ res });
          serviceX.setPushClaimRequestStatus(true);
        } catch (error) {
          serviceX.setPushClaimRequestStatus(false);
        }
      },
      () => {
        console.log('passport is dismissed');
      }
    );
  }

  function showServiceDetailHandler() {
    serviceX.showServiceInstance(MARKET_ID, [ProductType.BNPL_CONSUMER], () => {
      console.log('Service detail is dismissed');
    });
  }

  function showPromotionOffersHandler() {
    serviceX.showPromotionOffers(
      async (localId: string, credifyId: string) => {
        try {
          const res = await pushClaim(localId, credifyId);
          console.log({ res });
          serviceX.setPushClaimRequestStatus(true);
        } catch (error) {
          serviceX.setPushClaimRequestStatus(false);
        }
      },
      () => {
        console.log('Promotion offer is dismissed');
      }
    );
  }

  async function getDemoUsers() {
    setOffers([]);
    showLoading(true);
    try {
      const res = await fetch(`${DEMO_USER_URL}?id=${idText}`);
      const _user = await res.json();
      setUser(_user);
      const userProfile = {
        id: _user.id,
        phone_number: _user.phoneNumber,
        country_code: _user.phoneCountryCode,
        credify_id: _user.credifyId,
        first_name: _user.firstName,
        last_name: _user.lastName,
        full_name: _user.fullName,
      };
      onChangeText(_user.id);
      serviceX.setUserProfile(userProfile);
    } catch (error) {
      console.log(error);
    }
    showLoading(false);
  }

  function showOfferDetail(offerId: string) {
    serviceX.showOfferDetail(
      offerId,
      async (localId: string, credifyId: string) => {
        try {
          const res = await pushClaim(localId, credifyId);
          console.log({ res });
          serviceX.setPushClaimRequestStatus(true);
        } catch (error) {
          serviceX.setPushClaimRequestStatus(false);
        }
      },
      async (result: RedemptionStatus) => {
        console.log('**** redemtion result = ' + result);
        await getDemoUsers();
        await offerListHandler();
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
    <SafeAreaView style={styles.container}>
      <View style={{ marginTop: 10 }} />
      <Button onPress={getDemoUsers} title="Get Demo user" color="#841584" />

      <View style={{ marginTop: 10 }} />
      <Button
        onPress={offerListHandler}
        title="Get offer list"
        color="#841584"
      />

      <View style={{ marginTop: 10 }} />
      <Button
        onPress={showPromotionOffersHandler}
        title="Show Promotion Offers"
        color="#841584"
      />

      <View style={{ marginTop: 10 }} />
      <Button
        onPress={showPassportHandler}
        title="Show Passport"
        color="#841584"
      />

      <View style={{ marginTop: 10 }} />
      <Button
        onPress={showServiceDetailHandler}
        title="Show Service Detail"
        color="#841584"
      />

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
    </SafeAreaView>
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
