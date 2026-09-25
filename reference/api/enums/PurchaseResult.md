<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# PurchaseResult

_Enumeration_

**Fields**

| # | Name | Value | Type | Nilable | Default |
|---|---|---|---|---|---|
| 1 | `Ok` | 0 | `PurchaseResult` | no |  |
| 2 | `ErrorRiskDenied` | 1 | `PurchaseResult` | no |  |
| 3 | `ErrorOrderFailed` | 2 | `PurchaseResult` | no |  |
| 4 | `ErrorClientTimeout` | 3 | `PurchaseResult` | no |  |
| 5 | `ErrorClientDeclined` | 4 | `PurchaseResult` | no |  |
| 6 | `ErrorFailedToCreatePurchaseRecord` | 5 | `PurchaseResult` | no |  |
| 7 | `ErrorFailedToGetPurchaseID` | 6 | `PurchaseResult` | no |  |
| 8 | `ErrorFailedToSaveMopAndRiskStatus` | 7 | `PurchaseResult` | no |  |
| 9 | `ErrorFailedToSaveMopAndRiskResponse` | 8 | `PurchaseResult` | no |  |
| 10 | `ErrorClientGone` | 9 | `PurchaseResult` | no |  |
| 11 | `ErrorFailedToSavePlaceOrderStatus` | 10 | `PurchaseResult` | no |  |
| 12 | `ErrorBattlepayTimeoutMopAndRisk` | 11 | `PurchaseResult` | no |  |
| 13 | `ErrorCurrencyInvalidInRegion` | 12 | `PurchaseResult` | no |  |
| 14 | `ErrorBattlepayTemporarilyUnavailable` | 13 | `PurchaseResult` | no |  |
| 15 | `ErrorBattlepayDisabled` | 14 | `PurchaseResult` | no |  |
| 16 | `ErrorServerRestarted` | 15 | `PurchaseResult` | no |  |
| 17 | `ErrorInvalidProduct` | 16 | `PurchaseResult` | no |  |
| 18 | `ErrorInvalidRegionGroupMask` | 17 | `PurchaseResult` | no |  |
| 19 | `ErrorProductInvalidInRegion` | 18 | `PurchaseResult` | no |  |
| 20 | `ErrorDistributionObjectNotFound` | 19 | `PurchaseResult` | no |  |
| 21 | `ErrorDistributionObjectAlreadyAssigned` | 20 | `PurchaseResult` | no |  |
| 22 | `ErrorRiskResponseMissingScore` | 21 | `PurchaseResult` | no |  |
| 23 | `ErrorMopAndRiskAmqpRpcFailed` | 22 | `PurchaseResult` | no |  |
| 24 | `ErrorMopAndRiskRpcErrorFromBattlepay` | 23 | `PurchaseResult` | no |  |
| 25 | `ErrorMopAndRiskUnexpectedResponseFromBattlepay` | 24 | `PurchaseResult` | no |  |
| 26 | `ErrorMopAndRiskNoValidPaymentMethods` | 25 | `PurchaseResult` | no |  |
| 27 | `ErrorOrderCanceledPriceChange` | 26 | `PurchaseResult` | no |  |
| 28 | `ErrorBuyingProductNotAllowedInGlueScreen` | 27 | `PurchaseResult` | no |  |
| 29 | `ErrorMopAndRiskNotEnoughBalance` | 28 | `PurchaseResult` | no |  |
| 30 | `ErrorPlaceOrderNotEnoughBalance` | 29 | `PurchaseResult` | no |  |
| 31 | `ErrorProgrammerManualFail` | 30 | `PurchaseResult` | no |  |
| 32 | `ErrorThrottledByUserServer` | 31 | `PurchaseResult` | no |  |
| 33 | `ErrorBuyingProductNotAllowedInWorld` | 32 | `PurchaseResult` | no |  |
| 34 | `ErrorBlockedByParentalControls` | 33 | `PurchaseResult` | no |  |
| 35 | `ErrorNoStorePurchaseFlagIsSet` | 34 | `PurchaseResult` | no |  |
| 36 | `ErrorDistributionObjectInvalidChoice` | 35 | `PurchaseResult` | no |  |
| 37 | `ErrorInvalidCreditCardExpiryDate` | 36 | `PurchaseResult` | no |  |
| 38 | `ErrorAuthorizingPayment` | 37 | `PurchaseResult` | no |  |
| 39 | `ErrorPaymentProviderDeniedPayment` | 38 | `PurchaseResult` | no |  |
| 40 | `ErrorOverSpendingLimit` | 39 | `PurchaseResult` | no |  |
| 41 | `ErrorClientTimeoutChallenge` | 40 | `PurchaseResult` | no |  |
| 42 | `ErrorClientDeclinedChallenge` | 41 | `PurchaseResult` | no |  |
| 43 | `ErrorDistributionObjectInvalidTarget` | 42 | `PurchaseResult` | no |  |
| 44 | `ErrorFixedLicenseProductAlreadyExists` | 43 | `PurchaseResult` | no |  |
| 45 | `ErrorDistributionObjectTrialBlocked` | 44 | `PurchaseResult` | no |  |
| 46 | `ErrorDistributionObjectExpansionBlocked` | 45 | `PurchaseResult` | no |  |
| 47 | `ErrorOwnsConsumableToken` | 46 | `PurchaseResult` | no |  |
| 48 | `ErrorTooManyTokens` | 47 | `PurchaseResult` | no |  |
| 49 | `ErrorCommerceServerDisabled` | 48 | `PurchaseResult` | no |  |
| 50 | `ErrorFailedToWriteVasPurchaseID` | 49 | `PurchaseResult` | no |  |
| 51 | `ErrorFailedToWriteVasLicenseID` | 50 | `PurchaseResult` | no |  |
| 52 | `ErrorCharacterUpgradeOperationInProgress` | 51 | `PurchaseResult` | no |  |
| 53 | `ErrorInvalidPlatform` | 52 | `PurchaseResult` | no |  |
| 54 | `ErrorInvalidDeviceID` | 53 | `PurchaseResult` | no |  |
| 55 | `ErrorFailedToSaveValidatePurchaseStatus` | 54 | `PurchaseResult` | no |  |
| 56 | `ErrorFailedToSaveValidatePurchaseResponse` | 55 | `PurchaseResult` | no |  |
| 57 | `ErrorBattlepayTimeoutValidatePurchase` | 56 | `PurchaseResult` | no |  |
| 58 | `ErrorProductNotPurchasable` | 57 | `PurchaseResult` | no |  |
| 59 | `ErrorFailedToSaveClientCheckoutStatus` | 58 | `PurchaseResult` | no |  |
| 60 | `ErrorFailedOldPurchaseFlow` | 59 | `PurchaseResult` | no |  |
| 61 | `ErrorClientCheckoutTimeout` | 60 | `PurchaseResult` | no |  |
| 62 | `ErrorFailedToSaveValidationHashStatus` | 61 | `PurchaseResult` | no |  |
| 63 | `ErrorBattlepayTimeoutValidationHash` | 62 | `PurchaseResult` | no |  |
| 64 | `ErrorClientCheckoutCanceledOrFailed` | 63 | `PurchaseResult` | no |  |
| 65 | `ErrorCouldNotGetValidationHash` | 64 | `PurchaseResult` | no |  |
| 66 | `ErrorDistributionObjectWrongGameAccount` | 65 | `PurchaseResult` | no |  |
| 67 | `ErrorClientRestricted` | 66 | `PurchaseResult` | no |  |
| 68 | `ErrorFailedToSaveRedeemTokenStatus` | 67 | `PurchaseResult` | no |  |
| 69 | `ErrorInvalidPurchaseID` | 68 | `PurchaseResult` | no |  |
| 70 | `ErrorTokenRedemptionOrderFailed` | 69 | `PurchaseResult` | no |  |
| 71 | `ErrorVasTransactionCreateFailed` | 70 | `PurchaseResult` | no |  |
| 72 | `ErrorInManualReview` | 71 | `PurchaseResult` | no |  |

System: none (a shared table, filed in `APIDocumentation.tables`)
