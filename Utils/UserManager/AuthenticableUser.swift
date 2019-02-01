//
//  AuthenticableUser.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/23/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Foundation

/**
 Represents a user fetched from API.
 It stores a session token as an optional value, since it's expected to
 be received when the user is received from a new session (login or signup)
 and not in case the user is fetched using an implementation of `CurrentUserFetcherType`
 */
public protocol AuthenticableUser {
    
    // TODO: This should be refactored.
    // Probably as a struct that holds a sessionToken and a user.
    // sessionToken should not be part of the user properties.
    var sessionToken: String? { get }
    
}
