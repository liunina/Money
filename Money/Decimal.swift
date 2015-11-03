//
//  Decimal.swift
//  Money
//
//  Created by Daniel Thorpe on 29/10/2015.
//
//

import Foundation

// MARK: - NSDecimalNumber

public func ==(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.isEqualToNumber(rhs)
}

public func <(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

/**
 # NSDecimalNumber Extension
 These is an extension on NSDecimalNumber to support `DecimalNumberType` and
 `Decimal`. 
 
 Note that NSDecimalNumber cannot conform to `DecimalNumberType` directly
 because it is a framework class which cannot be made final, and the protocol
 has functions which return Self.
*/
extension NSDecimalNumber: Comparable {
    
    public var isNegative: Bool {
        return NSDecimalNumber.zero().compare(self) == .OrderedDescending
    }

    public func negateWithBehaviors(behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        let negativeOne = NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true)
        let result = decimalNumberByMultiplyingBy(negativeOne, withBehavior: behaviors)
        return result
    }
    
    @warn_unused_result
    public func subtract(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return decimalNumberBySubtracting(other, withBehavior: behaviors)
    }
    
    /**
     Add a matching `DecimalNumberType` to the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func add(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return decimalNumberByAdding(other, withBehavior: behaviors)
    }
    
    /**
     The remainder of dividing another `DecimalNumberType` into the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func remainder(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        let roundingMode: NSRoundingMode = Int(isNegative) ^ Int(other.isNegative) ? .RoundUp : .RoundDown
        let roundingBehaviors = NSDecimalNumberHandler(roundingMode: roundingMode, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let quotient = divideBy(other, withBehaviors: roundingBehaviors)
        let toSubtract = quotient.multiplyBy(other, withBehaviors: behaviors)
        let result = subtract(toSubtract, withBehaviors: behaviors)
        
        if result.isNegative {
            return result.negateWithBehaviors(behaviors)
        }
        return result
    }
    
    /**
     Multiply a matching `DecimalNumberType` with the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func multiplyBy(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return decimalNumberByMultiplyingBy(other, withBehavior: behaviors)
    }
    
    /**
     Divide the receiver by a matching `DecimalNumberType`.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    public func divideBy(other: NSDecimalNumber, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> NSDecimalNumber {
        return decimalNumberByDividingBy(other, withBehavior: behaviors)
    }
}

/**
 # DecimalNumberType
 A protocol which defines the necessary interface to support decimal number
 calculations and operators.
*/
public protocol DecimalNumberType: SignedNumberType, IntegerLiteralConvertible, FloatLiteralConvertible, CustomStringConvertible {
    
    typealias DecimalNumberBehavior: DecimalNumberBehaviorType
    
    /// Flag to indicate if the decimal number is less than zero
    var isNegative: Bool { get }
    
    /**
     Negates the receiver, equivalent to multiplying it by -1
     - returns: another instance of this type.
     */
    var negative: Self { get }
    
    /**
     Subtract a matching `DecimalNumberType` from the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    func subtract(_: Self, withBehaviors: NSDecimalNumberBehaviors?) -> Self
    
    /**
     Add a matching `DecimalNumberType` to the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    func add(_: Self, withBehaviors: NSDecimalNumberBehaviors?) -> Self
    
    /**
     The remainder of dividing another `DecimalNumberType` into the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    func remainder(_: Self, withBehaviors: NSDecimalNumberBehaviors?) -> Self
    
    /**
     Multiply a matching `DecimalNumberType` with the receiver.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    func multiplyBy(_: Self, withBehaviors: NSDecimalNumberBehaviors?) -> Self
    
    /**
     Divide the receiver by a matching `DecimalNumberType`.
     - parameter other: another instance of this type.
     - parameter behaviors: an optional NSDecimalNumberBehaviors?
     - returns: another instance of this type.
     */
    @warn_unused_result
    func divideBy(_: Self, withBehaviors: NSDecimalNumberBehaviors?) -> Self
}

// MARK: - Subtraction

@warn_unused_result
public func -<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.subtract(rhs, withBehaviors: T.DecimalNumberBehavior.decimalNumberBehaviors)
}

@warn_unused_result
public func -<T: DecimalNumberType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs - T(integerLiteral: rhs)
}

@warn_unused_result
public func -<T: DecimalNumberType>(lhs: T.IntegerLiteralType, rhs: T) -> T {
    return T(integerLiteral: lhs) - rhs
}

@warn_unused_result
public func -<T: DecimalNumberType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs - T(floatLiteral: rhs)
}

@warn_unused_result
public func -<T: DecimalNumberType>(lhs: T.FloatLiteralType, rhs: T) -> T {
    return T(floatLiteral: lhs) - rhs
}

// MARK: - Remainder

@warn_unused_result
public func %<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.remainder(rhs, withBehaviors: T.DecimalNumberBehavior.decimalNumberBehaviors)
}

// MARK: - Addition

@warn_unused_result
public func +<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.add(rhs, withBehaviors: T.DecimalNumberBehavior.decimalNumberBehaviors)
}

@warn_unused_result
public func +<T: DecimalNumberType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs + T(integerLiteral: rhs)
}

@warn_unused_result
public func +<T: DecimalNumberType>(lhs: T.IntegerLiteralType, rhs: T) -> T {
    return T(integerLiteral: lhs) + rhs
}

@warn_unused_result
public func +<T: DecimalNumberType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs + T(floatLiteral: rhs)
}

@warn_unused_result
public func +<T: DecimalNumberType>(lhs: T.FloatLiteralType, rhs: T) -> T {
    return T(floatLiteral: lhs) + rhs
}

// MARK: - Multiplication

@warn_unused_result
public func *<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.multiplyBy(rhs, withBehaviors: T.DecimalNumberBehavior.decimalNumberBehaviors)
}

@warn_unused_result
public func *<T: DecimalNumberType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs * T(integerLiteral: rhs)
}

@warn_unused_result
public func *<T: DecimalNumberType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs * T(floatLiteral: rhs)
}

@warn_unused_result
public func *<T: DecimalNumberType>(lhs: T.IntegerLiteralType, rhs: T) -> T {
    return rhs * lhs
}

@warn_unused_result
public func *<T: DecimalNumberType>(lhs: T.FloatLiteralType, rhs: T) -> T {
    return rhs * lhs
}

// MARK: - Division

@warn_unused_result
public func /<T: DecimalNumberType>(lhs: T, rhs: T) -> T {
    return lhs.divideBy(rhs, withBehaviors: T.DecimalNumberBehavior.decimalNumberBehaviors)
}

@warn_unused_result
public func /<T: DecimalNumberType>(lhs: T, rhs: T.IntegerLiteralType) -> T {
    return lhs / T(integerLiteral: rhs)
}

@warn_unused_result
public func /<T: DecimalNumberType>(lhs: T, rhs: T.FloatLiteralType) -> T {
    return lhs / T(floatLiteral: rhs)
}

/**
 # Decimal
 A value type which implements `DecimalNumberType` using `NSDecimalNumber` internally.
 
 It is generic over the decimal number behavior type, which defines the rounding
 and scale rules for base 10 decimal arithmetic.
*/
public struct _Decimal<Behavior: DecimalNumberBehaviorType>: DecimalNumberType {
    public typealias DecimalNumberBehavior = Behavior
    
    let value: NSDecimalNumber
    
    /// Flag to indicate if the decimal number is less than zero
    public var isNegative: Bool {
        return value.isNegative
    }
    
    public var negative: _Decimal {
        return _Decimal(value.negateWithBehaviors(Behavior.decimalNumberBehaviors))
    }

    public var description: String {
        return "\(value.description)"
    }

    init(_ decimalNumber: NSDecimalNumber = NSDecimalNumber.zero()) {
        value = decimalNumber
    }
    
    public init(floatLiteral value: FloatLiteralType) {
        self.value = NSDecimalNumber(floatLiteral: value).decimalNumberByRoundingAccordingToBehavior(Behavior.decimalNumberBehaviors)
    }
    
    public init(integerLiteral value: IntegerLiteralType) {
        switch value {
        case 0:
            self.value = NSDecimalNumber.zero()
        case 1:
            self.value = NSDecimalNumber.one()
        default:
            self.value = NSDecimalNumber(integerLiteral: value).decimalNumberByRoundingAccordingToBehavior(Behavior.decimalNumberBehaviors)
        }
    }

    @warn_unused_result
    public func subtract(other: _Decimal, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Decimal {
        return _Decimal(value.subtract(other.value, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func add(other: _Decimal, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Decimal {
        return _Decimal(value.add(other.value, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func remainder(other: _Decimal, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Decimal {
        return _Decimal(value.remainder(other.value, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func multiplyBy(other: _Decimal, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Decimal {
        return _Decimal(value.multiplyBy(other.value, withBehaviors: behaviors))
    }
    
    @warn_unused_result
    public func divideBy(other: _Decimal, withBehaviors behaviors: NSDecimalNumberBehaviors?) -> _Decimal {
        return _Decimal(value.divideBy(other.value, withBehaviors: behaviors))
    }
}

public func ==<B: DecimalNumberBehaviorType>(lhs: _Decimal<B>, rhs: _Decimal<B>) -> Bool {
    return lhs.value == rhs.value
}

public func <<B: DecimalNumberBehaviorType>(lhs: _Decimal<B>, rhs: _Decimal<B>) -> Bool {
    return lhs.value < rhs.value
}

extension NSNumberFormatter {

    func stringFromDecimal<B: DecimalNumberBehaviorType>(decimal: _Decimal<B>) -> String? {
        return stringFromNumber(decimal.value)
    }

    func formattedStringWithStyle<B: DecimalNumberBehaviorType>(style: NSNumberFormatterStyle) -> _Decimal<B> -> String {
        let currentStyle = numberStyle
        numberStyle = style
        let result: _Decimal<B> -> String = { decimal in
            return self.stringFromDecimal(decimal)!
        }
        numberStyle = currentStyle
        return result
    }
}

// MARK: - Conformance

public protocol DecimalNumberBehaviorType {

    /// Specify the decimal number (i.e. rounding, scale etc) for base 10 calculations
    static var decimalNumberBehaviors: NSDecimalNumberBehaviors? { get }
}

public struct DecimalNumberBehavior {

    private static func behaviorWithRoundingMode(mode: NSRoundingMode) -> NSDecimalNumberBehaviors? {
        return NSDecimalNumberHandler(roundingMode: mode, scale: 38, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
    }

    public struct Plain: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(.RoundPlain)
    }

    public struct RoundDown: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(.RoundDown)
    }

    public struct RoundUp: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(.RoundUp)
    }

    public struct Bankers: DecimalNumberBehaviorType {
        public static let decimalNumberBehaviors = DecimalNumberBehavior.behaviorWithRoundingMode(.RoundBankers)
    }
}

/// Standard `Decimal` with plain decimal number behavior
public typealias Decimal = _Decimal<DecimalNumberBehavior.Plain>



