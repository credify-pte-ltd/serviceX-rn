import { NativeModules } from 'react-native';
import type { components } from '@credify/api-docs';

type ServicexSdkRnType = {
  getOfferList(id: string): Promise<string>;
  showOfferDetail(id: string): void;
};

const ServicexSdkNative = NativeModules.ServicexSdkRn as ServicexSdkRnType;

export function init() {}

export async function getOffers(
  id: string
): Promise<components['OfferData'][]> {
  try {
    const jsonString = await ServicexSdkNative.getOfferList(id);
    const offerModel: components['OfferData'][] = JSON.parse(jsonString);
    return offerModel;
  } catch (error) {
    throw error;
  }
}

export function showOfferDetail(id: string) {
  ServicexSdkNative.showOfferDetail(id);
}

const ServiceXSdk = {
  init,
  getOffers,
  showOfferDetail,
};

export default ServiceXSdk;
