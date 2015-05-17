//: Playground - noun: a place where people can play

import UIKit

var myint = 0

extension Int {
    mutating func plusOne() {
        ++self
    }
    
    static func Random(#min: Int, max: Int) -> Int {
        if max < min { return min }
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
}

myint.plusOne()


myint = 10
myint.plusOne()
myint

Int.Random(min: 11, max: 20)