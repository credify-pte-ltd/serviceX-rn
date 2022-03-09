import { NativeEventEmitter, NativeModules } from 'react-native';
import type { components } from '@credify/api-docs';
import packageJson from '../package.json';
import { camelize } from './utils';

type PushClaimCB = (localId: string, credifyId: string) => void;

type RedemptionCB = (status: RedemptionStatus) => void;

type DismissCB = () => void;

const REDEEM_COMPLETED_EVENT = 'onRedeemCompleted';

export enum RedemptionStatus {
  PENDING,
  CANCELED,
  COMPLETED,
}

type OfferListRes = {
  credifyId: string;
  offerList: OfferData[];
};

export type OfferData = components['OfferData'] & {
  evaluationResult?: components['EvaluationResult'];
};

export type UserPayload = { [key: string]: string };

export type ThemeCustomizePayload = { [key: string]: any };

type ServicexSdkRnType = {
  initialize(
    apiKey: string,
    environment: string,
    marketName: string,
    packageVersion: string,
    theme?: ThemeCustomizePayload
  ): void;
  getOfferList(productTypes: string[]): Promise<string>;
  showOfferDetail(id: string, pushClaimCB: PushClaimCB): void;
  setUserProfile(payload: UserPayload): void;
  setPushClaimRequestStatus(isSuccess: boolean): void;
  clearCache(): void;
  showPassport(dismissCB: DismissCB): void;
};

const ServicexSdkNative = NativeModules.ServicexSdkRn as ServicexSdkRnType;

const eventEmitter = new NativeEventEmitter(NativeModules.ServicexSdkRn);

export function setRedempOfferCallback(cb: RedemptionCB) {
  eventEmitter.removeAllListeners(REDEEM_COMPLETED_EVENT);
  const subscription = eventEmitter.addListener(
    REDEEM_COMPLETED_EVENT,
    (event: any) => {
      if (cb) {
        cb(String(event.status).toUpperCase() as unknown as RedemptionStatus);
      }
      subscription.remove();
    }
  );
}

/**
 * Gets a list of offers after filtering for a specific user.
 * @param productTypes - Array of string: list of product_category and product_sub_category. Default is empty
 * @returns offer list response object
 */
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

/**
 * Clear SDK cache. Need to be called before starting a new redemption
 */
export function clearCache() {
  ServicexSdkNative.clearCache();
}

/**
 * Begin redemption flow
 * @param id - The id of the offer
 * @param pushClaimCB - The callback for organization to push their user's claim token
 */
export function showOfferDetail(
  id: string,
  pushClaimCB: PushClaimCB,
  redemptionCB?: RedemptionCB
) {
  if (redemptionCB) {
    setRedempOfferCallback(redemptionCB);
  }
  ServicexSdkNative.showOfferDetail(id, pushClaimCB);
}

/**
 * Set user info that need in other APIs such as showOfferDetail, getOffers, showPassport...
 * @param userProfile - user profile
 */
export function setUserProfile(userProfile: UserPayload) {
  ServicexSdkNative.setUserProfile(userProfile);
}

/**
 * Set push claim request's status.
 * @param isSuccess - status of push claim token's request
 */
export function setPushClaimRequestStatus(isSuccess: boolean) {
  ServicexSdkNative.setPushClaimRequestStatus(isSuccess);
}

/**
 * Show Credify passport page for user to login to see the offers's status
 * @param dismissCB - callback for dismiss action ( user close the passport window )
 */
export function showPassport(dismissCB: DismissCB) {
  ServicexSdkNative.showPassport(dismissCB);
}

/**
 * Instantiates the SDK
 * @param apiKey - The org's apiKey
 * @param environment - The development environment: "SANDBOX" or "PRODUCTION"
 * @param marketName - The name of the organization
 * */
export function initialize(
  apiKey: string,
  environment: string,
  marketName: string,
  theme: ThemeCustomizePayload
) {
  const packageVersion = packageJson.version;
  ServicexSdkNative.initialize(
    apiKey,
    environment,
    marketName,
    packageVersion,
    theme
  );
}

const serviceX = {
  initialize,
  getOffers,
  showOfferDetail,
  setUserProfile,
  setPushClaimRequestStatus,
  clearCache,
  showPassport,
};

export default serviceX;
