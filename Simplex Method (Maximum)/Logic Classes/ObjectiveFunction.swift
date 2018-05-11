//
//  ObjectiveFunction.swift
//  ARSimplexMethod
//
//  Created by Ahmed Ramy on 5/4/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import Foundation

public class ObjectiveFunction
{
    private var coefficients : [Double]
    public var VariablesCount: Int {return coefficients.count}
    public var Coefficients : [Double] {return coefficients}

    init(coefficients: [Double])
    {
        self.coefficients = coefficients
    }
    
    public func Value(variables: [Double]) -> Double
    {
        var value : Double = 0.0
        if VariablesCount != variables.count
        {
            fatalError("the number of variables must be equal to the coeffs of objFunc")
        }
        
        if self.coefficients.count > 0
        {
            for i in 0 ..< VariablesCount
            {
                value += self.coefficients[i] * variables[i]
            }
        }
        
        return value
    }
}
