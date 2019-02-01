//
//  KeychainService.swift
//  Utils
//
//  Created by Pablo Giorgi on 5/5/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import KeychainSwift

/**
 Protocol for keychain service.
 Provides a way to save, delete and query a String.
 */
public protocol KeychainServiceType {
    
    /**
     Returns the associated value given a key
     
     - Parameters:
     - key: key to get the associate value in case there is any
     - Returns:
     A String with the associated value
     */
    func get(key: String) -> String?
    
    /**
     Stores the value in under the given key
     
     - Parameters:
     - value: value associated to key
     - key: key to associate the value
     */
    func set(value: String, forKey key: String)
    
    /**
     Deletes the entry for the key
     
     - Parameters:
     - key: key to delete
     */
    func delete(key: String)
    
}

extension KeychainSwift: KeychainServiceType {
    
    public func get(key: String) -> String? {
        return get(key)
    }
    
    public func set(value: String, forKey key: String) {
        set(value, forKey: key)
    }
    
    public func delete(key: String) {
        delete(key)
    }
    
}
