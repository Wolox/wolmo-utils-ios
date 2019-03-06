//
//  UserManager.swift
//  Utils
//
//  Created by Pablo Giorgi on 3/2/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import ReactiveSwift
import Result
import KeychainSwift

/**
 Protocol for user manager.
 Includes the functions to handle the different session status changes,
 and properties to get the session properties.
 Also notifies when the session changed.
 */
public protocol UserManagerType {
    
    /**
     Bootstraps the session manager.
     This function loads the session token (in case there's any)
     and sends a session status change signal. It also fetches
     the user (in case a user fetcher has been provided) and sends
     a user change signal.
     */
    func bootstrap()
    
    /**
     Returns whether there is an active session.
     */
    var isLoggedIn: Bool { get }
    
    /**
     Returns the current session token in case there is an active session.
     */
    var sessionToken: String? { get }
    
    /**
     Returns the current user in case there is an active session.
     A current user fetcher must be provided for this property to have a value.
     */
    var currentUser: AuthenticableUser? { get }
    
    /**
     Signal that notifies each time the session status changes.
     Its value is a Bool representing whether there is an active session.
     Useful to handle the application status based on the session status.
     */
    var sessionSignal: Signal<Bool, NoError> { get }
    
    /**
     Signal that notifies each time the user changes.
     Its value is a User representing the current user.
     Useful to keep the user up to date any time it's fetched or updated.
     */
    var userSignal: Signal<AuthenticableUser?, NoError> { get }
    
    /**
     Set the current user fecther used to fetch the user when the
     session manager is bootstrapped.
     Unlike the session token, the user is not stored locally
     by the session manager. This is why it needs to be fetched
     during the bootstrapping.
     This should be called before bootstrap to have effect.
     */
    func setCurrentUserFetcher(currentUserFetcher: CurrentUserFetcherType)
    
    /**
     This function must be called manually when a user is logged in.
     It will send both a session and user notification.
     
     - Parameters:
     - user: user to initialize the session from.
     */
    func login(user: AuthenticableUser)
    
    /**
     This function can be called manually when a user is fetched from
     outside the session manager. In case the current user is wanted
     to be up to date with the fetched one.
     It will send both a session and user notification.
     
     - Parameters:
     - user: user to initialize the session from.
     */
    func update(user: AuthenticableUser)
    
    /**
     This function must be called manually, apart from the server's call,
     to log out the user.
     It will send both a session and user notification.
     */
    func logout()
    
    /**
     This function is called automatically by a repository when
     the session expires and the client is notified by the server.
     No need to be called manually.
     It only logs out the user in the session manager and notifies.
     */
    func expire()
    
}

/**
 Default UserManager responsible for handling the session in the application.
 It uses Keychain to store securely the session token in local storage, and a repository
 to fetch the user when it's bootstrapped.
 */
final public class UserManager: UserManagerType {
    fileprivate let _keychainService: KeychainServiceType
    fileprivate var _currentUserFetcher: CurrentUserFetcherType?
    
    fileprivate let _sessionToken = MutableProperty<String?>(.none)
    fileprivate let _currentUser = MutableProperty<AuthenticableUser?>(.none)
    
    public init(keychainService: KeychainServiceType = KeychainSwift()) {
        _keychainService = keychainService
    }
    
    public func setCurrentUserFetcher(currentUserFetcher: CurrentUserFetcherType) {
        // TODO: Check this doesn't cause a leak.
        _currentUserFetcher = currentUserFetcher
    }
    
    public func bootstrap() {
        _sessionToken.value = getSessionToken()
        if let currentUserFetcher = _currentUserFetcher, isLoggedIn {
            currentUserFetcher.fetchCurrentUser().startWithResult { [unowned self] in
                switch $0 {
                case .success(let user): self._currentUser.value = user
                case .failure: break // TODO: Handle error here.
                }
            }
        } else {
            _currentUser.value = .none
        }
    }
    
    public var isLoggedIn: Bool {
        return sessionToken != .none
    }
    
}

public extension UserManager {
    
    var sessionToken: String? {
        return _sessionToken.value
    }
    
    var currentUser: AuthenticableUser? {
        return _currentUser.value
    }
    
    var sessionSignal: Signal<Bool, NoError> {
        return _sessionToken.signal.map { $0 != .none }
    }
    
    var userSignal: Signal<AuthenticableUser?, NoError> {
        return _currentUser.signal
    }
    
}

public extension UserManager {
    
    public func login(user: AuthenticableUser) {
        guard !isLoggedIn else {
            fatalError("Attempting to login an already logged in session in SessionManager")
        }
        saveSessionToken(user: user)
        saveUser(user: user)
    }
    
    public func update(user: AuthenticableUser) {
        guard isLoggedIn else {
            fatalError("Attempting to update a non logged in session in SessionManager")
        }
        saveSessionToken(user: user)
        saveUser(user: user)
    }
    
    public func logout() {
        guard isLoggedIn else {
            fatalError("Attempting to logout a non logged in session in SessionManager")
        }
        clearSession()
    }
    
    public func expire() {
        guard isLoggedIn else {
            fatalError("Attempting to expire a non logged in session in SessionManager")
        }
        clearSession()
    }
    
}

private extension UserManager {
    
    func clearSession() {
        _sessionToken.value = .none
        _currentUser.value = .none
        clearSessionToken()
    }
    
    func saveSessionToken(user: AuthenticableUser) {
        _sessionToken.value = user.sessionToken
        if let sessionToken = user.sessionToken {
            saveSessionToken(sessionToken: sessionToken)
        } else {
            fatalError("Authenticated user has no session token, unable to save session in SessionManager")
        }
    }
    
    func saveUser(user: AuthenticableUser) {
        _currentUser.value = user
    }
    
}

private extension UserManager {
    
    private static let CurrentSessionTokenPersistanceKey = "com.wolox.wolmo-networking.CurrentSessionToken"
    
    func getSessionToken() -> String? {
        return _keychainService.get(key: UserManager.CurrentSessionTokenPersistanceKey)
    }
    
    func saveSessionToken(sessionToken: String) {
        _keychainService.set(value: sessionToken, forKey: UserManager.CurrentSessionTokenPersistanceKey)
    }
    
    func clearSessionToken() {
        _keychainService.delete(key: UserManager.CurrentSessionTokenPersistanceKey)
    }
    
}
