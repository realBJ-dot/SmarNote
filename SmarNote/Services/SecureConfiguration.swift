//
//  SecureConfiguration.swift
//  SmarNote
//
//  Created by Kiro on 7/23/25.
//

import Foundation
import Security

/// Secure configuration manager for production secrets
class SecureConfiguration {
    static let shared = SecureConfiguration()
    
    private init() {}
    
    // MARK: - Keychain Storage
    
    /// Store API key securely in Keychain
    func storeAPIKey(_ key: String, for service: String = "SmarNote-Groq") -> Bool {
        let data = key.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "api-key",
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieve API key from Keychain
    func retrieveAPIKey(for service: String = "SmarNote-Groq") -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "api-key",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    /// Delete API key from Keychain
    func deleteAPIKey(for service: String = "SmarNote-Groq") -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "api-key"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

// MARK: - Production Configuration
extension SecureConfiguration {
    
    /// Check if running in production environment
    var isProduction: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
    
    /// Get configuration based on environment
    func getGroqAPIKey() -> String? {
        // In production, always use user-provided key from Keychain
        if isProduction {
            return retrieveAPIKey()
        }
        
        // In development, check for environment variable first, then Keychain
        #if DEBUG
        if let envKey = ProcessInfo.processInfo.environment["GROQ_API_KEY"] {
            return envKey
        }
        return retrieveAPIKey()
        #else
        return retrieveAPIKey()
        #endif
    }
}