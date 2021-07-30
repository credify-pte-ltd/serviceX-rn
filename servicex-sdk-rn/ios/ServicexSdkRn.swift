@objc(ServicexSdkRn)
class ServicexSdkRn: NSObject {

    @objc(getOfferList:withResolver:withRejecter:)
    func getOfferList(id: String, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        let result = "{\"credifyId\":\"9ef14ef6-8730-4654-8093-57679f3b3c10\",\"offerList\":[{\"campaign\":{\"consumer\":{\"appUrl\":\"https://www.ocb.com.vn/\",\"description\":\"Ngân hàng TMCP Phương Đông OCB (Việt Nam)\",\"id\":\"8f530df6-98aa-4849-bcaf-d62705435266\",\"logoUrl\":\"https://i.imgur.com/9OHYvfP.jpg\",\"name\":\"OCB\",\"scopeNameList\":[\"openid\",\"phone\",\"email\",\"profile\"]},\"description\":\"Tạo Mới Thẻ Tín Dụng \",\"extraSteps\":false,\"id\":\"c95a5bf6-53fd-11eb-86e0-acde48001122\",\"levels\":[\"Hạn Mức 20.000.000 VNĐ\",\"Hạn Mức 50.000.000 VNĐ\"],\"name\":\"Tạo Mới Thẻ Tín Dụng \",\"publishedAt\":\"2020-12-01T06:15:14.865329Z\",\"thumbnailUrl\":\"https://s3-ap-southeast-1.amazonaws.com/credify.dev-test/banner-1.png\",\"useReferral\":false,\"verifiedScopes\":[]},\"conditionList\":[{\"claim\":{\"description\":\"Sendo Score\",\"displayName\":\"Sendo Score\",\"id\":\"350ac98b-32c1-11eb-8b7b-fa673376e2f7\",\"isActive\":true,\"mainClaimId\":\"\",\"maxValue\":\"200\",\"minValue\":\"0\",\"name\":\"3285592c-9aaf-4182-bff5-941ce5dac483:sendo%20score\",\"scope\":{\"claims\":[],\"createdAt\":\"2020-11-30T04:04:56.488841Z\",\"description\":\"Sendo score\",\"displayName\":\"Sendo Score\",\"id\":\"350a7a49-32c1-11eb-8b7b-fa673376e2f7\",\"isCustom\":true,\"isOneTimeCharge\":false,\"name\":\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo%20score\",\"price\":0.0,\"unit\":\"\",\"updatedAt\":\"2020-11-30T04:07:44.87447Z\"},\"scopeId\":\"350a7a49-32c1-11eb-8b7b-fa673376e2f7\",\"valueType\":\"INTEGER\"},\"kind\":\"IN_RANGE\"}],\"evaluationResult\":{\"rank\":1,\"requestedScopes\":[\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo%20score\"],\"usedScopes\":[\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo%20score\"]},\"id\":\"9391cda1-339c-11eb-8eb6-f631318b3464\",\"offerCode\":\"tao-moi-the-tin-dung\",\"providerId\":\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0\"},{\"campaign\":{\"consumer\":{\"appUrl\":\"https://www.ocb.com.vn/\",\"description\":\"Ngân hàng TMCP Phương Đông OCB (Việt Nam)\",\"id\":\"8f530df6-98aa-4849-bcaf-d62705435266\",\"logoUrl\":\"https://i.imgur.com/9OHYvfP.jpg\",\"name\":\"OCB\",\"scopeNameList\":[\"openid\",\"phone\",\"email\",\"profile\"]},\"description\":\"Hoàn tiền ngay khi mở thẻ OCB JCB Debit Card\",\"extraSteps\":false,\"id\":\"c9d2a962-53fd-11eb-86e0-acde48001122\",\"levels\":[\"Hoàn tiền 1% lên đến 1 triệu đồng\"],\"name\":\"Hoàn tiền ngay khi mở thẻ OCB JCB Debit Card\",\"publishedAt\":\"2020-12-04T11:20:52.564838Z\",\"thumbnailUrl\":\"https://s3-ap-southeast-1.amazonaws.com/credify.dev-test/banner-2.png\",\"useReferral\":false,\"verifiedScopes\":[]},\"conditionList\":[{\"claim\":{\"description\":\"Sendo Score\",\"displayName\":\"Sendo Score\",\"id\":\"350ac98b-32c1-11eb-8b7b-fa673376e2f7\",\"isActive\":true,\"mainClaimId\":\"\",\"maxValue\":\"200\",\"minValue\":\"0\",\"name\":\"3285592c-9aaf-4182-bff5-941ce5dac483:sendo%20score\",\"scope\":{\"claims\":[],\"createdAt\":\"2020-11-30T04:04:56.488841Z\",\"description\":\"Sendo score\",\"displayName\":\"Sendo Score\",\"id\":\"350a7a49-32c1-11eb-8b7b-fa673376e2f7\",\"isCustom\":true,\"isOneTimeCharge\":false,\"name\":\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo%20score\",\"price\":0.0,\"unit\":\"\",\"updatedAt\":\"2020-11-30T04:07:44.87447Z\"},\"scopeId\":\"350a7a49-32c1-11eb-8b7b-fa673376e2f7\",\"valueType\":\"INTEGER\"},\"kind\":\"IN_RANGE\"}],\"evaluationResult\":{\"rank\":1,\"requestedScopes\":[\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo%20score\"],\"usedScopes\":[\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo%20score\"]},\"id\":\"c4edf12c-3622-11eb-8807-1a63aca7904e\",\"offerCode\":\"hoan-tien-ngay-khi-mo-the\",\"providerId\":\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0\"},{\"campaign\":{\"consumer\":{\"appUrl\":\"https://www.ocb.com.vn/\",\"description\":\"Ngân hàng TMCP Phương Đông OCB (Việt Nam)\",\"id\":\"8f530df6-98aa-4849-bcaf-d62705435266\",\"logoUrl\":\"https://i.imgur.com/9OHYvfP.jpg\",\"name\":\"OCB\",\"scopeNameList\":[\"openid\",\"phone\",\"email\",\"profile\"]},\"description\":\"Hoàn tiền khi mua sắm online với thẻ tín dụng và thẻ ghi nợ quốc tế OCB\",\"extraSteps\":false,\"id\":\"cb8c54e2-53fd-11eb-86e0-acde48001122\",\"levels\":[\"Hoàn tiền 1% lên đến 2 triệu đồng\"],\"name\":\"Hoàn tiền khi mua sắm online với thẻ tín dụng và thẻ ghi nợ quốc tế OCB\",\"publishedAt\":\"2020-12-04T11:21:56.458596Z\",\"thumbnailUrl\":\"https://s3-ap-southeast-1.amazonaws.com/credify.dev-test/banner-3.png\",\"useReferral\":false,\"verifiedScopes\":[]},\"conditionList\":[{\"claim\":{\"description\":\"Sendo Score\",\"displayName\":\"Sendo Score\",\"id\":\"350ac98b-32c1-11eb-8b7b-fa673376e2f7\",\"isActive\":true,\"mainClaimId\":\"\",\"maxValue\":\"200\",\"minValue\":\"0\",\"name\":\"3285592c-9aaf-4182-bff5-941ce5dac483:sendo%20score\",\"scope\":{\"claims\":[],\"createdAt\":\"2020-11-30T04:04:56.488841Z\",\"description\":\"Sendo score\",\"displayName\":\"Sendo Score\",\"id\":\"350a7a49-32c1-11eb-8b7b-fa673376e2f7\",\"isCustom\":true,\"isOneTimeCharge\":false,\"name\":\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo%20score\",\"price\":0.0,\"unit\":\"\",\"updatedAt\":\"2020-11-30T04:07:44.87447Z\"},\"scopeId\":\"350a7a49-32c1-11eb-8b7b-fa673376e2f7\",\"valueType\":\"INTEGER\"},\"kind\":\"IN_RANGE\"}],\"evaluationResult\":{\"rank\":1,\"requestedScopes\":[\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo%20score\"],\"usedScopes\":[\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo%20score\"]},\"id\":\"eb035af5-3622-11eb-8807-1a63aca7904e\",\"offerCode\":\"hoan-tien-khi-mua-sam-online\",\"providerId\":\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0\"},{\"campaign\":{\"consumer\":{\"appUrl\":\"https://www.homecredit.vn\",\"description\":\"Home Credit Group (Home Credit B.V. and its subsidiaries) is a leading mass market consumer finance provider with €14.7bn of assets; which was established in 1997 in the Czech Republic. Since then it has experienced considerable growth in 10 countries including Rusia, Czech republic, Slovakia, Kazakhstan, China, Việt Nam, India….. Our 132,400 employees serve more than 70 million customers.\\n\\nHome Credit Vietnam officially operated in Vietnam since 2008, is one of the leading companies in the consumer financial field with 3 outstanding benefits for customers: fast, convenient and friendly. Home Credit now has the headquarters in HCMC and representative offices in 10 provinces nationwide.\\n\\nIn Vietnam market, Home Credit is now one of leading consumer finance companies. After 13 years of operation, Home Credit has built the network of 9,000 retail outlets in 63 cities and provinces nationwide.\",\"id\":\"5add4cad-6bdb-4bfb-af8d-c458feb632c9\",\"logoUrl\":\"https://uat-files.credify.dev/7508e81a-e097-459f-8dac-0f04e6b717ff.png\",\"name\":\"Home Credit\",\"scopeNameList\":[\"profile\",\"email\",\"phone\",\"openid\"]},\"description\":\"Tặng voucher Sendo 1 triệu đồng  khi vay mua xe máy\",\"extraSteps\":false,\"id\":\"b7410028-acb1-11eb-8ac9-62be994ed3d2\",\"levels\":[\"Tặng voucher Sendo 500k\",\"Tặng voucher Sendo 1.000k\"],\"name\":\"Tặng voucher Sendo 1 triệu đồng  khi vay mua xe máy\",\"publishedAt\":\"2021-05-04T08:21:29.246311Z\",\"thumbnailUrl\":\"https://uat-files.credify.dev/ac2d7666-6dd0-4784-986e-72995ec809c6.png\",\"useReferral\":false,\"verifiedScopes\":[]},\"conditionList\":[{\"kind\":\"AND\",\"subConditions\":[{\"kind\":\"AND\",\"subConditions\":[{\"claim\":{\"description\":\"purchase count\",\"displayName\":\"Purchase count\",\"id\":\"43d8d46c-9606-11ea-8c5d-5e3f1841c6e1\",\"isActive\":true,\"mainClaimId\":\"\",\"maxValue\":\"1000\",\"minValue\":\"0\",\"name\":\"3285592c-9aaf-4182-bff5-941ce5dac483:purchase-count\",\"scope\":{\"claims\":[],\"createdAt\":\"2020-05-14T17:13:44.023369Z\",\"description\":\"History data\",\"displayName\":\"Sendo History Data\",\"id\":\"43d51e25-9606-11ea-8c5d-5e3f1841c6e1\",\"isCustom\":true,\"isOneTimeCharge\":false,\"name\":\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo-history-data\",\"price\":0.0,\"unit\":\"\",\"updatedAt\":\"2020-11-30T04:07:44.870467Z\"},\"scopeId\":\"43d51e25-9606-11ea-8c5d-5e3f1841c6e1\",\"valueType\":\"INTEGER\"},\"kind\":\"IN_RANGE\"},{\"claim\":{\"description\":\"total payment amount\",\"displayName\":\"Total payment amount\",\"id\":\"43d6c33e-9606-11ea-8c5d-5e3f1841c6e1\",\"isActive\":true,\"mainClaimId\":\"\",\"maxValue\":\"1000000\",\"minValue\":\"0\",\"name\":\"3285592c-9aaf-4182-bff5-941ce5dac483:total-payment-amount\",\"scope\":{\"claims\":[],\"createdAt\":\"2020-05-14T17:13:44.023369Z\",\"description\":\"History data\",\"displayName\":\"Sendo History Data\",\"id\":\"43d51e25-9606-11ea-8c5d-5e3f1841c6e1\",\"isCustom\":true,\"isOneTimeCharge\":false,\"name\":\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo-history-data\",\"price\":0.0,\"unit\":\"\",\"updatedAt\":\"2020-11-30T04:07:44.870467Z\"},\"scopeId\":\"43d51e25-9606-11ea-8c5d-5e3f1841c6e1\",\"valueType\":\"FLOAT\"},\"kind\":\"IN_RANGE\"}]},{\"claim\":{\"description\":\"Sendo Score\",\"displayName\":\"Sendo Score\",\"id\":\"350ac98b-32c1-11eb-8b7b-fa673376e2f7\",\"isActive\":true,\"mainClaimId\":\"\",\"maxValue\":\"200\",\"minValue\":\"0\",\"name\":\"3285592c-9aaf-4182-bff5-941ce5dac483:sendo%20score\",\"scope\":{\"claims\":[],\"createdAt\":\"2020-11-30T04:04:56.488841Z\",\"description\":\"Sendo score\",\"displayName\":\"Sendo Score\",\"id\":\"350a7a49-32c1-11eb-8b7b-fa673376e2f7\",\"isCustom\":true,\"isOneTimeCharge\":false,\"name\":\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo%20score\",\"price\":0.0,\"unit\":\"\",\"updatedAt\":\"2020-11-30T04:07:44.87447Z\"},\"scopeId\":\"350a7a49-32c1-11eb-8b7b-fa673376e2f7\",\"valueType\":\"INTEGER\"},\"kind\":\"IN_RANGE\"}]},{\"kind\":\"AND\",\"subConditions\":[{\"kind\":\"AND\",\"subConditions\":[{\"claim\":{\"description\":\"purchase count\",\"displayName\":\"Purchase count\",\"id\":\"43d8d46c-9606-11ea-8c5d-5e3f1841c6e1\",\"isActive\":true,\"mainClaimId\":\"\",\"maxValue\":\"1000\",\"minValue\":\"0\",\"name\":\"3285592c-9aaf-4182-bff5-941ce5dac483:purchase-count\",\"scope\":{\"claims\":[],\"createdAt\":\"2020-05-14T17:13:44.023369Z\",\"description\":\"History data\",\"displayName\":\"Sendo History Data\",\"id\":\"43d51e25-9606-11ea-8c5d-5e3f1841c6e1\",\"isCustom\":true,\"isOneTimeCharge\":false,\"name\":\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo-history-data\",\"price\":0.0,\"unit\":\"\",\"updatedAt\":\"2020-11-30T04:07:44.870467Z\"},\"scopeId\":\"43d51e25-9606-11ea-8c5d-5e3f1841c6e1\",\"valueType\":\"INTEGER\"},\"kind\":\"IN_RANGE\"},{\"claim\":{\"description\":\"total payment amount\",\"displayName\":\"Total payment amount\",\"id\":\"43d6c33e-9606-11ea-8c5d-5e3f1841c6e1\",\"isActive\":true,\"mainClaimId\":\"\",\"maxValue\":\"1000000\",\"minValue\":\"0\",\"name\":\"3285592c-9aaf-4182-bff5-941ce5dac483:total-payment-amount\",\"scope\":{\"claims\":[],\"createdAt\":\"2020-05-14T17:13:44.023369Z\",\"description\":\"History data\",\"displayName\":\"Sendo History Data\",\"id\":\"43d51e25-9606-11ea-8c5d-5e3f1841c6e1\",\"isCustom\":true,\"isOneTimeCharge\":false,\"name\":\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo-history-data\",\"price\":0.0,\"unit\":\"\",\"updatedAt\":\"2020-11-30T04:07:44.870467Z\"},\"scopeId\":\"43d51e25-9606-11ea-8c5d-5e3f1841c6e1\",\"valueType\":\"FLOAT\"},\"kind\":\"IN_RANGE\"}]},{\"claim\":{\"description\":\"Sendo Score\",\"displayName\":\"Sendo Score\",\"id\":\"350ac98b-32c1-11eb-8b7b-fa673376e2f7\",\"isActive\":true,\"mainClaimId\":\"\",\"maxValue\":\"200\",\"minValue\":\"0\",\"name\":\"3285592c-9aaf-4182-bff5-941ce5dac483:sendo%20score\",\"scope\":{\"claims\":[],\"createdAt\":\"2020-11-30T04:04:56.488841Z\",\"description\":\"Sendo score\",\"displayName\":\"Sendo Score\",\"id\":\"350a7a49-32c1-11eb-8b7b-fa673376e2f7\",\"isCustom\":true,\"isOneTimeCharge\":false,\"name\":\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo%20score\",\"price\":0.0,\"unit\":\"\",\"updatedAt\":\"2020-11-30T04:07:44.87447Z\"},\"scopeId\":\"350a7a49-32c1-11eb-8b7b-fa673376e2f7\",\"valueType\":\"INTEGER\"},\"kind\":\"IN_RANGE\"}]}],\"evaluationResult\":{\"rank\":2,\"requestedScopes\":[\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo-history-data\",\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo%20score\"],\"usedScopes\":[\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo-history-data\",\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0:sendo%20score\"]},\"id\":\"b745ada2-acb1-11eb-8ac9-62be994ed3d2\",\"offerCode\":\"t-ng-voucher-sendo-1-tri-u---ng--khi-vay-mua-xe-m-y-sendo-dd805722-a748-4742-ba03-a1f3605b28fe\",\"providerId\":\"b09e8f99-6d89-4e7d-83ea-a43a1787b3e0\"}]}"
        resolve(result)
    }
 
}