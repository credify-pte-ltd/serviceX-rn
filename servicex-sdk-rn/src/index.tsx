import { NativeModules } from 'react-native';
import type { components } from '@credify/api-docs';

type PushClaimCB = (localId: string, credifyId: string) => void;

type ServicexSdkRnType = {
  initialize(apiKey: string, environment: string, marketName: string): void;
  getOfferList(): Promise<string>;
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

export async function getOffers(): Promise<OfferListRes> {
  try {
    const jsonString = await ServicexSdkNative.getOfferList();
    const offerRes: OfferListRes = JSON.parse(jsonString);
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

export function showReferralResult() {
  ServicexSdkNative.showReferral();
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
  ServicexSdkNative.initialize(apiKey, environment, marketName);
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
