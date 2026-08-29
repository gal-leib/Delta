//
//  RevenueCatManager.swift
//  Delta
//
//  Created by Riley Testut on 11/11/24.
//  Copyright © 2024 Riley Testut. All rights reserved.
//

import Foundation

@available(iOS 17.5, *)
extension RevenueCatManager
{
    static let didUpdateCustomerInfoNotification = Notification.Name("DLTADidUpdateCustomerInfoNotification")
    
    struct User: Decodable
    {
        var id: String
        var name: String?
    }
    
    struct Entitlement: RawRepresentable, Codable, Hashable
    {
        static let betaAccess = Entitlement(rawValue: "beta-access")
        static let discord = Entitlement(rawValue: "discord")
        static let credits = Entitlement(rawValue: "credits")
        
        let rawValue: String
    }
    
    struct EntitlementInfo
    {
        var isActive: Bool = true
    }
    
    struct CustomerInfo
    {
        struct Entitlements
        {
            var all: [String: EntitlementInfo] = [
                "beta-access": EntitlementInfo(isActive: true),
                "discord": EntitlementInfo(isActive: true),
                "credits": EntitlementInfo(isActive: true)
            ]
        }
        var entitlements = Entitlements()
    }
        
    enum Error: LocalizedError
    {
        case unknownProduct
        case disabled
        
        var errorDescription: String? {
            switch self
            {
            case .unknownProduct: return NSLocalizedString("There is no product with the requested ID.", comment: "")
            case .disabled: return NSLocalizedString("In-App Purchases are disabled.", comment: "")
            }
        }
    }
    
    enum Subscription: Identifiable
    {
        case earlyAdopter
        case communityMember
        case friendZone
        
        var id: Self {
            return self
        }
        
        var title: String {
            switch self
            {
            case .earlyAdopter: return String(localized: "Early Adopter")
            case .communityMember: return String(localized: "Community Member")
            case .friendZone: return String(localized: "Friend Zone")
            }
        }
    }
}

@available(iOS 17.5, *) @MainActor
class RevenueCatManager
{
    static let shared = RevenueCatManager()
    
    private(set) var isStarted: Bool = false
    private(set) var customerInfo: CustomerInfo?
    
    var entitlements: [Entitlement: EntitlementInfo] {
        return [
            .betaAccess: EntitlementInfo(isActive: true),
            .discord: EntitlementInfo(isActive: true),
            .credits: EntitlementInfo(isActive: true)
        ]
    }
    
    var displayName: String? {
        return Keychain.shared.revenueCatDisplayName
    }
    
    var emailAddress: String? {
        return Keychain.shared.revenueCatEmailAddress
    }
    
    var hasBetaAccess: Bool {
        return true
    }
    
    var hasPastBetaAccess: Bool {
        return true
    }
    
    private init()
    {
    }
    
    func start() async throws
    {
        self.isStarted = true
        self.customerInfo = CustomerInfo()
    }
    
    func setDisplayName(_ name: String) async throws
    {
        Keychain.shared.revenueCatDisplayName = name
    }
    
    func setEmailAddress(_ emailAddress: String) async throws
    {
        Keychain.shared.revenueCatEmailAddress = emailAddress
    }
    
    func purchase(_ subscription: Subscription) async throws
    {
        throw Error.disabled
    }
    
    func requestRestorePurchases() async throws
    {
    }
    
    @discardableResult
    func fetchFriendZoneUsers() async throws -> [User]
    {
        return []
    }
    
    @discardableResult
    func fetchUser(id: String) async throws -> User
    {
        return User(id: id, name: nil)
    }
}
