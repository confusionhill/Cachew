//
//  CachewMain.swift
//  Cachew
//
//  Created by terminal on 01/02/23.
//

import Foundation

public final class Cachew<ValueType> {
    
    private let wrapper = NSCache<CachewKey, CachewValue>()
    private var keys = [String]()
    
    public func get(key: String) -> ValueType? {
        let obj = self.getObj(key: key)
        return obj?.value
    }
    
    public init() {}
    
    public func get() -> [ValueType?] {
        var values = [ValueType?]()
        keys.forEach { key in
            values.append(get(key: key))
        }
        return values
    }
    
    private func getObj(key: String) -> CachewValue? {
        if let obj = wrapper.object(forKey: .init(key)) {
            if obj.ttl != nil, obj.ttl!.isBefore() {
                return obj
            }
            self.delete(key: key)
        }
        
        return nil
    }
    
    public func set(key: String, value: Cachew<ValueType>.CachewValue) {
        if !keys.contains(key) {
            keys.append(key)
        }
        wrapper.setObject(value, forKey: .init(key))
    }
    
    public func isExist(key: String) -> Bool {
        return getObj(key: key) != nil
    }
    
    public func delete(key: String) {
        if isExist(key: key) {
            wrapper.removeObject(forKey: .init(key))
        }
    }
    
    public func delete() {
        wrapper.removeAllObjects()
    }
    
}

extension Cachew {
    public final class CachewValue {
        let value: ValueType
        let ttl: Date?
        
        init(value: ValueType, ttl: Date? = nil) {
            self.value = value
            self.ttl = ttl
        }
        
    }
    
    public final class CachewKey: NSObject {
        let key: String
        
        init(_ key: String) {
            self.key = key
        }
        
        public override func isEqual(_ object: Any?) -> Bool {
            guard let object = object as? CachewKey else {
                return false
            }
            return object.key == key
        }
    }
}

fileprivate extension Date {
    func isBefore()-> Bool {
        return Date().timeIntervalSince(self) <= 0
    }
}
