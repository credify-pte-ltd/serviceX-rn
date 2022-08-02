import { NativeEventEmitter, NativeModules } from 'react-native';
import type { components } from '@credify/api-docs';
import packageJson from '../package.json';
import { camelize } from './utils';
import type { serviceXThemeConfig } from './theme';

type PushClaimCB = (localId: string, credifyId: string) => void;

type RedemptionCB = (status: RedemptionStatus) => void;

type DismissCB = () => void;

export enum RedemptionStatus {
  PENDING,
  CANCELED,
  COMPLETED,
}

const NATIVE_EVENT = 'nativeEvent';

enum EventType {
  COMPLETION = 'completion',
  REDEEM_COMPLETED = 'redeemCompleted',
  PUSH_CLAIM_TOKEN = 'pushClaimToken',
}

export enum ProductType {
  // Insurance
  INSURANCE = 'insurance',
  HEALTH_INSURANCE = 'health-insurance',
  AUTO_MOBILE_INSURANCE = 'automobile-insurance',
  HOME_INSURANCE = 'home-insurance',
  // BNPL
  BNPL_CONSUMER = 'consumer-financing:unsecured-loan:bnpl',
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
    theme?: serviceXThemeConfig
  ): void;
  getOfferList(productTypes: string[]): Promise<string>;
  showOfferDetail(id: string): void;
  showPromotionOffers(): void;
  setUserProfile(payload: UserPayload): void;
  setPushClaimRequestStatus(isSuccess: boolean): void;
  clearCache(): void;
  showPassport(): void;
  showServiceInstance(marketId: string, productTypes: ProductType[]): void;
};

const ServicexSdkNative = NativeModules.ServicexSdkRn as ServicexSdkRnType;

const eventEmitter = new NativeEventEmitter(NativeModules.ServicexSdkRn);

let _redemptionCB: RedemptionCB | undefined;
let _pushClaimCB: PushClaimCB | undefined;
let _dismissCB: DismissCB | undefined;

function subscribeEvent() {
  eventEmitter.removeAllListeners(NATIVE_EVENT);
  eventEmitter.addListener(NATIVE_EVENT, (event: any) => {
    console.log('Received event: ', event);
    onReceiveEvent(event);
  });
  console.log('Subscribed event: ' + NATIVE_EVENT);
}

function onReceiveEvent(event: any) {
  if (!event) return;

  const payload = event.payload;

  switch (event.type) {
    case EventType.PUSH_CLAIM_TOKEN: {
      _pushClaimCB?.(payload.localId, payload.credifyId);
      break;
    }
    case EventType.REDEEM_COMPLETED: {
      _redemptionCB?.(
        String(event.status).toUpperCase() as unknown as RedemptionStatus
      );
      break;
    }
    case EventType.COMPLETION: {
      _dismissCB?.();

      _dismissCB = undefined;
      _pushClaimCB = undefined;
      _redemptionCB = undefined;
      break;
    }
    default: {
      console.log('Unsupported event type: ' + event.type);
    }
  }
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
 * @param redemptionCB - The callback notifies that the page is closed
 */
export function showOfferDetail(
  id: string,
  pushClaimCB: PushClaimCB,
  redemptionCB?: RedemptionCB
) {
  _pushClaimCB = pushClaimCB;
  _redemptionCB = redemptionCB;

  ServicexSdkNative.showOfferDetail(id);
}

/**
 * Begin redemption flow
 * @param pushClaimCB - The callback for organization to push their user's claim token
 * @param redemptionCB - The callback notifies that the page is closed
 */
export function showPromotionOffers(
  pushClaimCB: PushClaimCB,
  redemptionCB?: RedemptionCB
) {
  _pushClaimCB = pushClaimCB;
  _redemptionCB = redemptionCB;

  ServicexSdkNative.showPromotionOffers();
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
 * Show Credify passport page for user to login to see the offer's status
 * @param pushClaimCB - The callback for organization to push their user's claim token
 * @param dismissCB - callback for dismiss action ( user close the passport window )
 */
export function showPassport(pushClaimCB: PushClaimCB, dismissCB: DismissCB) {
  _pushClaimCB = pushClaimCB;
  _dismissCB = dismissCB;

  ServicexSdkNative.showPassport();
}

/**
 * Show Service detail page for user
 * @param marketId - Your organization that has registered with Credify
 * @param productTypes - product type list
 */
export function showServiceInstance(
  marketId: string,
  productTypes: ProductType[],
  dismissCB: DismissCB
) {
  _dismissCB = dismissCB;

  ServicexSdkNative.showServiceInstance(marketId, productTypes);
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
  subscribeEvent();
}

const serviceX = {
  initialize,
  getOffers,
  showOfferDetail,
  showPromotionOffers,
  setUserProfile,
  setPushClaimRequestStatus,
  clearCache,
  showPassport,
  showServiceInstance,
};

export default serviceX;
