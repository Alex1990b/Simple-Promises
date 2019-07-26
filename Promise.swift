//
//  Promise.swift
//
//  Created by Alex on 5/21/19.
//  Copyright © 2019 alex. All rights reserved.
//

import Foundation

typealias Resolver<T> = (
    _ resolve: @escaping (T) -> Void,
    _ reject:  @escaping (Error?) -> Void
    ) -> Void

final class Promise<Value> {
    
    private let resolver: Resolver<Value>
    
    init(_ resolver: @escaping Resolver<Value>) {
        self.resolver = resolver
    }
    
    @discardableResult
    func then(_ closure: @escaping (Value) -> Void) -> Promise<Value> {
        resolver({ value in closure(value) }, { _ in })
        return self
    }
    
    @discardableResult
    func then<U>(_ closure: @escaping (Value) -> Promise<U>) -> Promise<U> {
        var promise: Promise<U>?
        resolver({ value in promise = closure(value) }, { _ in })
        return Promise<U> { resolve, reject in
            promise?.then { result in
                resolve(result)
            }
            promise?.fail { error in
                reject(error)
            }
        }
    }
    
    func fail(_ closure: @escaping (Error?) -> Void)  {
        resolver({ _ in }, { error in closure(error) })
    }
    
    @discardableResult
    func fail<U>(_ closure: @escaping (Error?) -> Promise<U>) -> Promise<U> {
        var promise: Promise<U>?
        
        resolver({ _ in }, { error in promise = closure(error) })
        
        return Promise<U> { resolve, reject in
            promise?.then { result in
                resolve(result)
            }
            promise?.fail { error in
                reject(error)
            }
        }
    }
}
