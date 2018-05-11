//
//  Constraint.swift
//  ARSimplexMethod
//
//  Created by Ahmed Ramy on 5/4/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import Foundation

class Constraint
{
    private var coefficients: [Double]
    private var restriction: Double
    private var coefficientsCount: Int
    public var Coefficients: [Double] {return coefficients}
    public var Restriction: Double {return restriction}
    
    init(coefficients: [Double], restriction: Double)
    {
        self.coefficients = coefficients
        self.restriction = restriction
        self.coefficientsCount = coefficients.count
    }
    
}
