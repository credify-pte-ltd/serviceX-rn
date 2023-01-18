import Credify

@objc(ServicexSdkRn)
class ServicexSdkRn: RCTEventEmitter {
    
    private var offerIns: Any?
    private var passportIns: Any?
    private var bnplIns: Any?
    var listOffer: [OfferData] = [OfferData]()
    var userInput: NSDictionary?
    var pushClaimResponseCallback: ((Bool) -> Void)?
    
    private let nativeEvent = "nativeEvent"
    
    enum EventType: String {
        case completion
        case redeemCompleted
        case pushClaimToken
        case bnplRedeemCompleted
    }
    
    class UnmanagedError : Error {
        var error: String
        
        init() {
            self.error = "Unmanaged error"
        }
    }
    
    private func createEventPayload(type: String, payload: [String : Any?]) -> [String : Any?] {
        return [
            "type": type,
            "payload": payload
        ]
    }
    
    private func sendEvent(payload: [String : Any?]) {
        self.sendEvent(withName: self.nativeEvent, body: payload)
    }
    
    private func sendPushClaimTokenEvent(localId: String, credifyId: String) {
        let payload = self.createEventPayload(
            type: EventType.pushClaimToken.rawValue,
            payload: [
                "localId": localId,
                "credifyId": credifyId
            ]
        )
        self.sendEvent(payload: payload)
    }
    
    private func sendRedeemedOfferEvent(status: String?) {
        let payload = self.createEventPayload(
            type: EventType.redeemCompleted.rawValue,
            payload: [
                "status": status
            ]
        )
        self.sendEvent(payload: payload)
    }
    
    private func sendBNPLRedeemedOfferEvent(status: String?, orderId: String, isPaymentCompleted: Bool) {
        let payload = self.createEventPayload(
            type: EventType.bnplRedeemCompleted.rawValue,
            payload: [
                "status": status,
                "orderId": orderId,
                "isPaymentCompleted": isPaymentCompleted,
            ]
        )
        self.sendEvent(payload: payload)
    }
    
    private func sendCompletionEvent() {
        let payload = self.createEventPayload(
            type: EventType.completion.rawValue,
            payload: [:]
        )
        self.sendEvent(payload: payload)
    }
    
    @objc(initialize:marketId:environment:marketName:packageVersion:theme:)
    func initialize(
        apiKey:String,
        marketId: String,
        environment: String,
        marketName: String,
        packageVersion: String,
        theme: NSDictionary
    ) -> Void {
        passportIns = serviceX.Passport()
        offerIns = serviceX.Offer()
        bnplIns = serviceX.BNPL()
        
        let envDict = ["DEV": CredifyEnvs.dev, "PRODUCTION": .production,"SANDBOX":  .sandbox,"SIT": .sit,"UAT": .uat]
        let themeData = parseThemeObject(value: theme)
        let config = serviceXConfig(apiKey: apiKey, marketId: marketId, env: envDict[environment]!, appName: marketName, theme: themeData ?? serviceXTheme.default, userAgent: "servicex/rn/ios/\(packageVersion)")
        serviceX.configure(config)
    }
    
    func parseThemeObject(value:NSDictionary) -> serviceXTheme? {
        guard let v = value as? [String:Any] else { return nil }
        let color = v["color"] as? [String:Any]
        let font = v["font"] as? [String:Any]
        
        // Color theme:
        let primaryBrandyStart = color?["primaryBrandyStart"] as? String
        let primaryBrandyEnd =  color?["primaryBrandyEnd"] as? String
        let primaryText = color?["primaryText"] as? String
        let secondaryActive = color?["secondaryActive"] as? String
        let secondaryDisable = color?["secondaryDisable"] as? String
        let secondaryText = color?["secondaryText"] as? String
        let secondaryComponentBackground = color?["secondaryComponentBackground"] as? String
        let secondaryBackground = color?["secondaryBackground"] as? String
        let primaryButtonTextColor = color?["primaryButtonTextColor"] as? String
        let primaryButtonBrandyStart = color?["primaryButtonBrandyStart"] as? String
        let primaryButtonBrandyEnd = color?["primaryButtonBrandyEnd"] as? String
        
        // Font theme:
        let primaryFontFamily = font?["primaryFontFamily"] as? String ?? ThemeFont.default.primaryFontFamily
        let secondaryFontFamily = font?["secondaryFontFamily"] as? String ?? ThemeFont.default.secondaryFontFamily
        let bigTitleFontSize = font?["bigTitleFontSize"] as? Int ?? serviceXTheme.default.font.bigTitleFontSize
        let bigTitleFontLineHeight = font?["bigTitleFontLineHeight"] as? Int ?? serviceXTheme.default.font.bigTitleFontLineHeight
        let modelTitleFontSize = font?["modelTitleFontSize"] as? Int ?? serviceXTheme.default.font.modelTitleFontSize
        let modelTitleFontLineHeight = font?["modelTitleFontLineHeight"] as? Int ?? serviceXTheme.default.font.modelTitleFontLineHeight
        let sectionTitleFontSize = font?["sectionTitleFontSize"] as? Int ?? serviceXTheme.default.font.sectionTitleFontSize
        let sectionTitleFontLineHeight = font?["sectionTitleFontLineHeight"] as? Int ?? serviceXTheme.default.font.sectionTitleFontLineHeight
        let bigFontSize = font?["bigFontSize"] as? Int ?? serviceXTheme.default.font.bigFontSize
        let bigFontLineHeight = font?["bigFontLineHeight"] as? Int ?? serviceXTheme.default.font.bigFontLineHeight
        let normalFontSize = font?["normalFontSize"] as? Int ?? serviceXTheme.default.font.normalFontSize
        let normalFontLineHeight = font?["normalFontLineHeight"] as? Int ?? serviceXTheme.default.font.normalFontLineHeight
        let smallFontSize = font?["smallFontSize"] as? Int ?? serviceXTheme.default.font.smallFontSize
        let smallFontLineHeight = font?["smallFontLineHeight"] as? Int ?? serviceXTheme.default.font.smallFontLineHeight
        let boldFontSize = font?["boldFontSize"] as? Int ?? serviceXTheme.default.font.boldFontSize
        let boldFontLineHeight = font?["smallFontLineHeight"] as? Int ?? serviceXTheme.default.font.boldFontLineHeight
        
        // Overall
        let inputFieldRadius = v["inputFieldRadius"] as? Double ?? serviceXTheme.default.inputFieldRadius
        let modelRadius = v["modelRadius"] as? Double ?? serviceXTheme.default.modalRadius
        let buttonRadius = v["buttonRadius"] as? Double ?? serviceXTheme.default.buttonRadius
        let boxShadow = v["boxShadow"] as? String ?? serviceXTheme.default.boxShadow
        
        let themeColor = ThemeColor(primaryBrandyStart: primaryBrandyStart ?? ThemeColor.default.primaryBrandyStart,
                               primaryBrandyEnd: primaryBrandyEnd ?? ThemeColor.default.primaryBrandyEnd,
                               primaryText: primaryText ?? ThemeColor.default.primaryText,
                               secondaryActive: secondaryActive ?? ThemeColor.default.secondaryActive,
                               secondaryDisable: secondaryDisable ?? ThemeColor.default.secondaryDisable,
                               secondaryText: secondaryText ?? ThemeColor.default.secondaryText,
                               secondaryComponentBackground: secondaryComponentBackground ?? ThemeColor.default.secondaryComponentBackground,
                               secondaryBackground: secondaryBackground ?? ThemeColor.default.secondaryBackground,
                               primaryButtonTextColor: primaryButtonTextColor ?? ThemeColor.default.primaryButtonTextColor,
                               primaryButtonBrandyStart: primaryButtonBrandyStart ?? ThemeColor.default.primaryButtonBrandyStart,
                               primaryButtonBrandyEnd: primaryButtonBrandyEnd ?? ThemeColor.default.primaryButtonBrandyEnd
                               
        )
        
        let themeFont = ThemeFont(
            primaryFontFamily: primaryFontFamily,
            secondaryFontFamily: secondaryFontFamily,
            bigTitleFontSize: bigTitleFontSize,
            bigTitleFontLineHeight: bigTitleFontLineHeight,
            modelTitleFontSize: modelTitleFontSize,
            modelTitleFontLineHeight: modelTitleFontLineHeight,
            sectionTitleFontSize: sectionTitleFontSize,
            sectionTitleFontLineHeight: sectionTitleFontLineHeight,
            bigFontSize: bigFontSize,
            bigFontLineHeight: bigFontLineHeight,
            normalFontSize: normalFontSize,
            normalFontLineHeight: normalFontLineHeight,
            smallFontSize: smallFontSize,
            smallFontLineHeight: smallFontLineHeight,
            boldFontSize: boldFontSize,
            boldFontLineHeight: boldFontLineHeight
        )
        
        let theme = serviceXTheme(color: themeColor,
                                  font: themeFont,
                                  inputFieldRadius: inputFieldRadius,
                                  modelRadius: modelRadius,
                                  buttonRadius: buttonRadius,
                                  boxShadow: boxShadow)
        return theme
    }
    
    func parseUserProfile(value:NSDictionary) -> CredifyUserModel? {
        guard let v = value as? [String:Any] else { return nil }
        if let id = v["id"] as? Int {
            let firstName = v["first_name"] as? String ?? ""
            let lastName =  v["last_name"] as? String ?? ""
            let fullName =  v["full_name"] as? String
            let email = v["email"] as? String ?? ""
            let credifyId = v["credify_id"] as? String
            let phoneNumber = v["phone_number"] as? String
            let phoneCountryCode = v["country_code"] as? String
            
            return CredifyUserModel(id: "\(id)",
                                    firstName: firstName,
                                    lastName: lastName,
                                    fullName: fullName,
                                    email: email,
                                    credifyId: credifyId,
                                    countryCode: phoneCountryCode ?? "",
                                    phoneNumber: phoneNumber ?? "")
        }
        return nil
    }
    
    func parseOrderInfo(value:NSDictionary) -> OrderInfo? {
        guard let v = value as? [String:Any] else { return nil }
        if let orderId = v["orderId"] as? String, let orderAmountDic =  v["orderAmount"] as? [String:Any] {
            if let value = orderAmountDic["value"] as? String, let currency = orderAmountDic["currency"] as? String, let currencyType = CurrencyType.init(rawValue: currency) {
                return OrderInfo(
                    orderId: orderId,
                    orderAmount: FiatCurrency(value: value, currency: currencyType)
                )
            }
        }
        
        return nil
    }
    
    @objc override func supportedEvents() -> [String]! {
        return [nativeEvent]
    }
    
    @objc(setUserProfile:)
    func setUserProfile(value:NSDictionary) {
        userInput = value
    }
    
    struct OfferListRes: Codable {
        let credifyId: String?
        let offerList: [OfferData]
    }
    
    struct BNPLInfoRes: Codable {
        let isAvailable: Bool
        let credifyId: String?
    }
    
    @objc(getOfferList:resolve:rejecter:)
    func getOfferList(productTypes: NSArray, resolve: @escaping(RCTPromiseResolveBlock), rejecter reject: @escaping(RCTPromiseRejectBlock)) -> Void {
        guard let ui = userInput else {
            print("User input was not found")
            return
        }
        let user = self.parseUserProfile(value: ui)
        guard let _productTypes = productTypes as? [String] else { reject("CredifySDK error","productTypes must be a string array", nil)
            return
        }
        
        var parsedProductTypes: [ProductType] = []
        _productTypes.forEach { item in
            guard let type = ProductType(rawValue: item) else {
                return
            }
            parsedProductTypes.append(type)
        }
        
        if let offerIns = offerIns as? serviceX.Offer
        {
            offerIns.getOffers(user: user, productTypes: parsedProductTypes) { [weak self] result in
                switch result {
                case .success(let offerListInfo):
                    self?.listOffer = offerListInfo.offers
                    let offerListRes = OfferListRes(credifyId: user?.credifyId, offerList: offerListInfo.offers)
                    let jsonEncoder = JSONEncoder()
                    do{
                        
                        let jsonData = try jsonEncoder.encode(offerListRes)
                        let json = String(data: jsonData, encoding: .utf8)
                        resolve(json)
                    }catch let error as NSError {
                        reject("CredifySDK error","parsing json error", error)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
        
    @objc(setPushClaimRequestStatus:)
    func setPushClaimRequestStatus(isSuccess: Bool){
        self.pushClaimResponseCallback?(isSuccess)
        // Dereference callback to avoid memory leak
        self.pushClaimResponseCallback = nil
    }
    
    
    func redemptionResultString(type: RedemptionResult) -> String {
        switch type {
        case .completed:
            return "completed"
        case .canceled:
            return "canceled"
        case .pending:
            return "pending"
        @unknown default:
            return "unknown"
            
        }
    }
    
    @objc(showOfferDetail:)
    func showOfferDetail(offerId: String) {
        
        guard let ui = userInput else {
            print("User input was not found")
            return
        }
        guard let user = self.parseUserProfile(value: ui) else {
            print("User was not found")
            return
        }
        
        let offerData = self.listOffer.first(where: { item -> Bool in
            item.id == offerId
        })
        
        guard let offerData = offerData else {
            print("Offer was not found")
            return
        }
        
        DispatchQueue.main.async {
            guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
                print("There is no view controller")
                return
            }
            
            let task: ((String, ((Bool) -> Void)?) -> Void) = { credifyId, result in
                self.sendPushClaimTokenEvent(localId: user.id, credifyId: credifyId)
                self.pushClaimResponseCallback = result
            }
            
            if let offerIns = self.offerIns as? serviceX.Offer
            {
                offerIns.presentModally(
                    from: vc,
                    offer: offerData,
                    userProfile: user,
                    pushClaimTokensTask: task
                ) { [weak self] result in
                    self?.sendRedeemedOfferEvent(status: self?.redemptionResultString(type: result))
                    self?.sendCompletionEvent()
                }
            }
        }
    }
    
    @objc(showPromotionOffers)
    func showPromotionOffers() {
        guard let ui = userInput else {
            print("User input was not found")
            return
        }
        guard let user = self.parseUserProfile(value: ui) else {
            print("User was not found")
            return
        }

        let offers = self.listOffer

        if offers.isEmpty {
            print("Offers is empty")
            return
        }

        DispatchQueue.main.async {
            guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
                print("There is no view controller")
                return
            }

            let task: ((String, ((Bool) -> Void)?) -> Void) = { credifyId, result in
                self.sendPushClaimTokenEvent(localId: user.id, credifyId: credifyId)
                self.pushClaimResponseCallback = result
            }

            if let offerIns = self.offerIns as? serviceX.Offer
            {
                offerIns.presentPromotionOffersModally(
                    from: vc,
                    offers: offers,
                    userProfile: user,
                    pushClaimTokensTask: task
                ) { [weak self] result in
                    self?.sendRedeemedOfferEvent(status: self?.redemptionResultString(type: result))
                    self?.sendCompletionEvent()
                }
            }
        }
    }
    
    @objc(showPassport)
    func showPassport(){
        guard let ui = userInput else {
            print("User input was not found")
            return
        }
        guard let user = self.parseUserProfile(value: ui) else {
            print("User was not found")
            return
        }
        
        let task: ((String, ((Bool) -> Void)?) -> Void) = { credifyId, result in
            self.sendPushClaimTokenEvent(localId: user.id, credifyId: credifyId)
            self.pushClaimResponseCallback = result
        }
        
        DispatchQueue.main.async {
            guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
                print("There is no view controller")
                return
            }
            
            if let passportIns = self.passportIns as? serviceX.Passport
            {
                passportIns.showMypage(from: vc, user: user, pushClaimTokensTask: task) {
                    self.sendCompletionEvent()
                }
            }
        }
    }
    
    @objc(showServiceInstance:productTypes:)
    func showServiceInstance(marketId: String, productTypes: NSArray){
        guard let ui = userInput else {
            print("User input was not found")
            return
        }
        guard let user = self.parseUserProfile(value: ui) else {
            print("User was not found")
            return
        }

        guard let _productTypes = productTypes.map({item in ProductType.init(rawValue: item as! String)}) as? [ProductType] else {
            print("Product type is not correct")
            return
        }

        DispatchQueue.main.async {
            guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
                print("There is no view controller")
                return
            }

            if let passportIns = self.passportIns as? serviceX.Passport
            {
                passportIns.showDetail(from: vc, user: user, marketId: marketId, productTypes: _productTypes) {
                    self.sendCompletionEvent()
                }
            }
        }
    }
    
    @objc(getBNPLAvailability:rejecter:)
    func getBNPLAvailability(resolve: @escaping(RCTPromiseResolveBlock), rejecter reject: @escaping(RCTPromiseRejectBlock)){
        guard let ui = userInput else {
            print("User input was not found")
            return
        }
        guard let user = self.parseUserProfile(value: ui) else {
            print("User was not found")
            return
        }
        
        if let bnplIns = self.bnplIns as? serviceX.BNPL {
            bnplIns.getBNPLAvailability(user: user, completion: { result in
                switch result {
                case .success(let bnplInfo):
                    let jsonEncoder = JSONEncoder()
                    do{
                        
                        let jsonData = try jsonEncoder.encode(
                            BNPLInfoRes(
                                isAvailable: bnplInfo.available,
                                credifyId: bnplInfo.credifyId
                            )
                        )
                        let json = String(data: jsonData, encoding: .utf8)
                        resolve(json)
                    } catch let error as NSError {
                        reject("CredifySDK error","parsing json error", error)
                    }
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
    
    @objc(showBNPL:)
    func showBNPL(orderInfo: NSDictionary){
        guard let ui = userInput else {
            print("User input was not found")
            return
        }
        guard let user = self.parseUserProfile(value: ui) else {
            print("User was not found")
            return
        }
        
        let orderInfo = parseOrderInfo(value: orderInfo)
        
        let task: ((String, ((Bool) -> Void)?) -> Void) = { credifyId, result in
            self.sendPushClaimTokenEvent(localId: user.id, credifyId: credifyId)
            self.pushClaimResponseCallback = result
        }
        
        DispatchQueue.main.async {
            guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
                print("There is no view controller")
                return
            }

            if let bnplIns = self.bnplIns as? serviceX.BNPL {
                bnplIns.presentModally(
                    from: vc,
                    userProfile: user,
                    orderInfo: orderInfo!,
                    pushClaimTokensTask: task
                ) { [weak self] status, orderId, isPaymentCompleted  in
                    self?.sendBNPLRedeemedOfferEvent(
                        status: self?.redemptionResultString(type: status),
                        orderId: orderId,
                        isPaymentCompleted: isPaymentCompleted
                    )
                    self?.sendCompletionEvent()
                }
            }
        }
    }
    
    @objc(startFlow:)
    func startFlow(appUrl: NSString){
        DispatchQueue.main.async {
            guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
                print("There is no view controller")
                return
            }

            if let bnplIns = self.bnplIns as? serviceX.BNPL {
                bnplIns.presentModallyFlow(from: vc, appUrl: appUrl as String, completionHandler: {[weak self] in
                    self?.sendCompletionEvent()
                })
            }
        }
    }
}
