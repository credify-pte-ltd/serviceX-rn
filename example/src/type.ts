import type { CurrencyType } from 'servicex-rn';

export interface OrderLine {
  name: string;
  reference_id: string;
  imageUrl: string;
  productUrl: string;
  quantity: number;
  unitPrice: TotalAmount;
  subtotal: TotalAmount;
  measurementUnit: string;
}

export interface TotalAmount {
  value: string;
  currency: CurrencyType;
}

export interface PaymentRecipient {
  type: string;
  bank_account?: PaymentRecipientDetail;
}

export interface PaymentRecipientDetail {
  name: string;
  number: string;
  branch: string;
  bank: string;
}

export interface OrderInfo {
  referenceId: string;
  totalAmount: TotalAmount;
  orderLines: OrderLine[];
  paymentRecipient: PaymentRecipient;
  userId: string;
}

export interface OrderInfoResponse {
  id: string;
  referenceId: string;
  totalAmount: TotalAmount;
  orderLines: OrderLine[];
  paymentRecipient: PaymentRecipient;
  orderStatus: string;
  bnplAccountNumber: string;
}
