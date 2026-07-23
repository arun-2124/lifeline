import { UserRole, AccountStatus } from '../config/constants';

export interface LifelineCustomClaims {
  role: UserRole;
  accountStatus: AccountStatus;
  termsAccepted: boolean;
  lastRoleChangeTimestamp?: number;
}

export interface UserProfileDocument {
  uid: string;
  email: string;
  role: UserRole;
  accountStatus: AccountStatus;
  termsAccepted: boolean;
  termsAcceptedAt?: string;
  lastRoleChangeAt?: string;
  donorDetails?: {
    fssaiLicenseNumber?: string;
    organizationName?: string;
    contactPhone: string;
    address: string;
  };
  ngoDetails?: {
    registrationNumber: string;
    darpanId?: string;
    organizationName: string;
    contactPhone: string;
    address: string;
  };
  recipientDetails?: {
    fullName: string;
    idProofNumber: string;
    contactPhone: string;
    address: string;
  };
  createdAt: string;
  updatedAt: string;
  deletedAt?: string;
  isAnonymized?: boolean;
}

export interface ValidateProfilePayload {
  role: UserRole;
  termsAccepted: boolean;
  idempotencyKey: string;
  donorDetails?: {
    fssaiLicenseNumber?: string;
    organizationName?: string;
    contactPhone: string;
    address: string;
  };
  ngoDetails?: {
    registrationNumber: string;
    darpanId?: string;
    organizationName: string;
    contactPhone: string;
    address: string;
  };
  recipientDetails?: {
    fullName: string;
    idProofNumber: string;
    contactPhone: string;
    address: string;
  };
}

export interface CheckAccountStatusResponse {
  uid: string;
  email: string;
  role: UserRole;
  accountStatus: AccountStatus;
  claimsSynced: boolean;
  requiresOnboarding: boolean;
  cooldownDaysRemaining: number;
}
