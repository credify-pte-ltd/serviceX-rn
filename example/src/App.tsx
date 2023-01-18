import * as React from 'react';
import { useEffect, useState } from 'react';
import Spinner from 'react-native-loading-spinner-overlay';

import {
  Alert,
  Button,
  FlatList,
  Image,
  Platform,
  SafeAreaView,
  StyleSheet,
  Text,
  TextInput,
  ToastAndroid,
  TouchableOpacity,
  View,
} from 'react-native';
import serviceX, {
  CurrencyType,
  OfferData,
  ProductType,
  RedemptionStatus,
  UserPayload,
} from 'servicex-rn';
import type { serviceXThemeConfig } from '../../src/theme';
import type { PaymentRecipient, TotalAmount } from './type';

const ENV = 'SANDBOX';

// Offer
const API_KEY =
  '7kx6vx9p9gZmqrtvHjRTOiSXMkAfZB3s5u3yjLehQHQCtjWrjAk9XlQHR2IOqpuR';
const PUSH_CLAIM_URL =
  'https://sandbox-demo-api.credify.dev/housecare/push-claims';
const DEMO_USER_URL =
  'https://sandbox-demo-api.credify.dev/housecare/demo-user';
const MARKET_NAME = 'housecare';
const MARKET_ID = '039f059a-3d58-4592-b359-834f5fe9a442';

// BNPL
const BNPL_API_KEY =
  'UwbxwqQXnY66dtQm57Bt98la4AwSQodUeMyNThny4aQ7SVoN9IDrhctBCkgWdt6W';
const BNPL_PUSH_CLAIM_URL =
  'https://sandbox-demo-api.credify.dev/bnpl-consumer/push-claims';
const BNPL_DEMO_USER_URL =
  'https://sandbox-demo-api.credify.dev/bnpl-consumer/demo-user';
const BNPL_CREATE_INTENT_URL =
  'https://sandbox-demo-api.credify.dev/bnpl-consumer/intents';
const BNPL_MARKET_NAME = 'BNPL Consumer';
const BNPL_MARKET_ID = '8319dd85-7b57-4455-a8dc-5fb1d142a400';

enum FlowType {
  NONE,
  OFFER,
  BNPL,
}

export default function App() {
  const [user, setUser] = useState<any>(null);
  const [userPayload, setUserPayload] = useState<UserPayload>();
  const [idText, onChangeText] = useState<string>('');
  const [offersData, setOffers] = useState<OfferData[]>([]);
  const [isLoading, showLoading] = useState<boolean>(false);
  const [selectedFlow, setSelectedFlow] = useState<FlowType>(FlowType.NONE);

  const customTheme: serviceXThemeConfig = {
    color: {
      primaryBrandyStart: '#87E4E4',
      primaryBrandyEnd: '#87E4E4',
      primaryButtonBrandyStart: '#ED7C5C',
      primaryButtonBrandyEnd: '#F3B270',
      primaryText: '#222D41',
      secondaryText: '#999999',
      secondaryBackground: '#FFFFFF',
      secondaryComponentBackground: '#EFF5FF',
      primaryWhite: '#FFFFFF',
      secondaryActive: '#87E4E4',
      secondaryDisable: '#E0E0E0',
      primaryButtonTextColor: '#FFFFFF',
      topBarTextColor: '#FFFFFF',
    },
    font: {
      primaryFontFamily: 'Inter',
      secondaryFontFamily: 'Inter',
      bigTitleFontSize: 21,
      bigTitleFontLineHeight: 37,
      pageHeaderFontSize: 21,
      pageHeaderLineHeight: 31,
      modelTitleFontSize: 20,
      modelTitleFontLineHeight: 29,
      sectionTitleFontSize: 16,
      sectionTitleFontLineHeight: 24,
      sectionTitleSmallFontSize: 14,
      sectionTitleSmallFontLineHeight: 21,
      buttonFontSize: 17,
      buttonFontLineHeight: 25,
      bigFontSize: 18,
      bigFontLineHeight: 26,
      normalFontSize: 14,
      normalFontLineHeight: 18,
      smallFontSize: 14,
      smallFontLineHeight: 20,
      boldFontSize: 15,
      boldFontLineHeight: 21,
    },
    inputFieldRadius: 10,
    modelRadius: 10,
    buttonRadius: 50,
    boxShadow: '0px 4px 30px rgba(0, 0, 0, 0.1)',
  };

  useEffect(() => {
    if (selectedFlow === FlowType.OFFER) {
      serviceX.initialize(API_KEY, MARKET_ID, ENV, MARKET_NAME, customTheme);
    } else if (selectedFlow === FlowType.BNPL) {
      serviceX.initialize(
        BNPL_API_KEY,
        BNPL_MARKET_ID,
        ENV,
        BNPL_MARKET_NAME,
        customTheme
      );
    }

    if (selectedFlow !== FlowType.NONE) {
      getDemoUsers();
    }
  }, [selectedFlow]);

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
          updateCredifyId(credifyId);

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
          updateCredifyId(credifyId);

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
      let url = DEMO_USER_URL;
      if (selectedFlow === FlowType.BNPL) {
        url = BNPL_DEMO_USER_URL;
      }
      console.log('Get user url', url);

      const res = await fetch(`${url}?id=${idText}`);
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
      setUserPayload(userProfile);
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
          updateCredifyId(credifyId);

          const res = await pushClaim(localId, credifyId);
          console.log({ res });
          serviceX.setPushClaimRequestStatus(true);
        } catch (error) {
          serviceX.setPushClaimRequestStatus(false);
        }
      },
      async (result: RedemptionStatus) => {
        showMessage(`Redemption result: ${result}`);
        await getDemoUsers();
        await offerListHandler();
      }
    );
  }

  async function pushClaim(localId: string, credifyId: string) {
    let url = PUSH_CLAIM_URL;
    if (selectedFlow === FlowType.BNPL) {
      url = BNPL_PUSH_CLAIM_URL;
    }
    console.log('Push claim url', url);

    const body = {
      id: localId,
      credify_id: credifyId,
    };
    try {
      const res = await fetch(url, {
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

  const createOrderInfo = () => {
    const paymentRecipient: PaymentRecipient = {
      type: 'BANK_ACCOUNT',
      bank_account: {
        name: 'bank_name',
        number: '213232323',
        branch: 'bank_branch',
        bank: 'bank_bank',
      }
    };

    const orderLines = [
      {
        name: 'Diane 35 - Bayer (H/21v)',
        reference_id: 'reference_id_1',
        image_url: 'https://apharma.vn/wp-content/uploads/Diane-35.png',
        product_url: 'https://apharma.vn/wp-content/uploads/Diane-35.png',
        quantity: 20,
        unit_price: { value: '115000', currency: CurrencyType.VND },
        subtotal: { value: `${115000 * 20}`, currency: CurrencyType.VND },
        measurement_unit: 'EA',
        category: 'MOBILE_DEVICE',
      },
      {
        name: 'Marvelon Bayer (H/21v)',
        reference_id: 'reference_id_2',
        image_url:
          'https://images.fpt.shop/unsafe/fit-in/600x600/filters:quality(90):fill(white)/nhathuoclongchau.com/images/product/2021/05/00004687-marvelon-h3-vi-7225-60ad_large.jpg',
        product_url:
          'https://images.fpt.shop/unsafe/fit-in/600x600/filters:quality(90):fill(white)/nhathuoclongchau.com/images/product/2021/05/00004687-marvelon-h3-vi-7225-60ad_large.jpg',
        quantity: 70,
        unit_price: { value: '63100', currency: CurrencyType.VND },
        subtotal: { value: `${63100 * 70}`, currency: CurrencyType.VND },
        measurement_unit: 'EA',
        category: 'MOBILE_DEVICE',
      },
    ];

    const totalAmount: TotalAmount = {
      value: orderLines
        .reduce(
          (partialSum, item) => partialSum + Number(item.subtotal.value),
          0
        )
        .toString(),
      currency: CurrencyType.VND,
    };

    return {
      reference_id: `reference_id_${new Date().getTime()}`,
      total_amount: totalAmount,
      order_lines: orderLines,
      payment_recipient: paymentRecipient,
    };
  };

  const createIntent = async (): Promise<{ id: string; appUrl: string }> => {
    try {
      const payload = JSON.stringify({
        type: 'BNPL',
        bnpl_order: createOrderInfo(),
        user: {
          id: `${user.id}`,
          phone: {
            phone_number: user.phoneNumber,
            country_code: user.phoneCountryCode,
          },
          credify_id: user.credifyId,
          first_name: user.firstName,
          last_name: user.lastName,
          full_name: user.fullName,
          name: user.name,
          email: user.email,
        },
        service: {
          ui: {
            theme: customTheme
          }
        }
      });
      const res = await fetch(BNPL_CREATE_INTENT_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: payload,
      });
      const result = await res.json();
      return { id: result.id, appUrl: result.appUrl };
    } catch (error) {
      console.log('error', error);
      throw error;
    }
  };

  const startBNPL = async () => {
    try {
      showLoading(true);
      const result = await createIntent();
      showLoading(false);

      console.log("Intent info", result);

      // Without using setTimeout, cannot open a the page in iOS
      // iOS message: Attempt to present <UINavigationController: 0x7ff09f027800> on <UIViewController: 0x7ff09f80c7d0> (from <UIViewController: 0x7ff09f80c7d0>) which is already presenting <RCTModalHostViewController: 0x7ff09fa1ff60>.
      setTimeout(() => {
        serviceX.startFlow(result.appUrl, () => {
          console.log('BNPL page is closed');
        });
      }, 0);
    } catch (e) {
      showLoading(false);
      console.log('Cannot create order', e);
    }
  };

  const showDetails = () => {
    serviceX.showServiceInstance(
      BNPL_MARKET_ID,
      [ProductType.BNPL_CONSUMER],
      () => {
        console.log('Detail page is dismissed');
      }
    );
  };

  const showMessage = (message: string) => {
    console.log('showMessage', message);
    if (Platform.OS === 'android') {
      ToastAndroid.show(message, ToastAndroid.SHORT);
    } else {
      Alert.alert(message);
    }
  };

  const updateCredifyId = (credifyId: string) => {
    const newUser = {
      ...userPayload,
      credify_id: credifyId,
    };
    setUserPayload(newUser);
    serviceX.setUserProfile(newUser);
  };

  return (
    <SafeAreaView style={styles.container}>
      {selectedFlow === FlowType.OFFER && (
        <View>
          <View style={{ marginTop: 10 }} />
          <Button
            onPress={getDemoUsers}
            title="Get Demo user"
            color="#841584"
          />

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
        </View>
      )}

      {selectedFlow === FlowType.BNPL && (
        <View>
          <View style={{ marginTop: 10 }} />
          <Button
            onPress={getDemoUsers}
            title="Get Demo user"
            color="#841584"
          />

          <View style={{ marginTop: 10 }} />
          <Button onPress={startBNPL} title="Start BNPL" color="#841584" />

          <View style={{ marginTop: 10 }} />
          <Button onPress={showDetails} title="Show Details" color="#841584" />
        </View>
      )}

      {selectedFlow !== FlowType.NONE && (
        <View>
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
        </View>
      )}

      {selectedFlow === FlowType.NONE && (
        <View>
          <View style={{ marginTop: 10 }} />
          <Button
            onPress={() => setSelectedFlow(FlowType.OFFER)}
            title="Offer Flow"
            color="#841584"
          />

          <View style={{ marginTop: 10 }} />
          <Button
            onPress={() => setSelectedFlow(FlowType.BNPL)}
            title="BNPL Flow"
            color="#841584"
          />
        </View>
      )}

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
