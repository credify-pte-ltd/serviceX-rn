import { NativeModules } from 'react-native';
import type { components } from '@credify/api-docs';
import packageJson from '../package.json';
import { camelize } from './utils';

type PushClaimCB = (localId: string, credifyId: string) => void;

type ServicexSdkRnType = {
  initialize(
    apiKey: string,
    environment: string,
    marketName: string,
    packageVersion: string
  ): void;
  getOfferList(productTypes: string[]): Promise<string>;
  showOfferDetail(id: string, pushClaimCB: PushClaimCB): void;
  setUserProfile(payload: UserPayload): void;
  setPushClaimRequestStatus(isSuccess: boolean): void;
  clearCache(): void;
};

type OfferListRes = {
  credifyId: string;
  offerList: OfferData[];
};

export type OfferData = components['OfferData'] & {
  evaluationResult?: components['EvaluationResult'];
};

export type UserPayload = { [key: string]: string };

const ServicexSdkNative = NativeModules.ServicexSdkRn as ServicexSdkRnType;

export async function getOffers(
  productTypes: string[] = []
): Promise<OfferListRes> {
  try {
    const jsonString = await ServicexSdkNative.getOfferList(productTypes);
    const offerRes: OfferListRes = camelize(JSON.parse(jsonString));
    return offerRes;
  } catch (error) {
    throw error;
  }
}

export function clearCache() {
  ServicexSdkNative.clearCache();
}

export function showOfferDetail(id: string, pushClaimCB: PushClaimCB) {
  ServicexSdkNative.showOfferDetail(id, pushClaimCB);
}

export function setUserProfile(payload: UserPayload) {
  ServicexSdkNative.setUserProfile(payload);
}

export function setPushClaimRequestStatus(isSuccess: boolean) {
  ServicexSdkNative.setPushClaimRequestStatus(isSuccess);
}

export function initialize(
  apiKey: string,
  environment: string,
  marketName: string
) {
  const packageVersion = packageJson.version;
  ServicexSdkNative.initialize(apiKey, environment, marketName, packageVersion);
}

const ServiceXSdk = {
  initialize,
  getOffers,
  showOfferDetail,
  setUserProfile,
  setPushClaimRequestStatus,
  clearCache,
};

export default ServiceXSdk;
