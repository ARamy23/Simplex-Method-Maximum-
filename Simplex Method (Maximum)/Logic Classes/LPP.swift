//
//  LLP.swift
//  ARSimplexMethod
//
//  Created by Ahmed Ramy on 5/4/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import Foundation

class LPP
{
    public var ObjFunc: ObjectiveFunction
    public var Constraints: [Constraint]
    public var Variables: [Double]
    
    
    init(objFunc: ObjectiveFunction, constraints: [Constraint])
    {
        self.ObjFunc = objFunc
        self.Constraints = constraints
        self.Variables = Array(repeating: 0, count: ObjFunc.VariablesCount)
    }
    
    public func isSolutionFound(dictionary: Dictionary) -> Bool
    {
        return dictionary.entersBasis() == -1
    }
    
    public func solve() -> Dictionary
    {
        var dict = Dictionary(LPP: self)
        if !dict.isFeasible() {dict = self.initialize()}
        print("Finding a solution .........")
        print("-------------------------------")
        print()
        
        while(!isSolutionFound(dictionary: dict))
        {
            dict.display()
            dict.improve()
        }
        
        dict.display()
        for i in 0 ..< dict.basicVars.count
        {
            if dict.basicVars[i] < Variables.count + 1
            {
                Variables[dict.basicVars[i] - 1] = 0
            }
        }
        
        for i in 0 ..< dict.slackVars.count
        {
            if dict.slackVars[i] < Variables.count + 1
            {
                Variables[dict.slackVars[i] - 1] = dict.c[i][0]
            }
        }
        
        return dict
    }
    
    private func initialize() -> Dictionary
    {
        print("Initialization Phase ...")
        print("-------------------------------")
        print()
        var auxC : [Double] = Array(repeating: 0, count: ObjFunc.VariablesCount+1)
        auxC[0] = -1
        for i in 0 ..< auxC.count - 1
        {
            auxC[i+1] = 0
        }
        
        let auxOF: ObjectiveFunction = ObjectiveFunction(coefficients: auxC)
        var auxCS: [Constraint] = [Constraint]()
        var leaveBasis = 0
        var minB = Constraints[0].Restriction
        for i in 0 ..< Constraints.count
        {
            var auxCC : [Double] = Array(repeating: 0.0, count: ObjFunc.VariablesCount + 1)
            auxCC[0] = -1
            for j in 0 ..< auxCC.count - 1 {auxCC[j+1] = Constraints[i].Coefficients[j]}
            auxCS[i] = Constraint(coefficients: auxCC, restriction: Constraints[i].Restriction)
            if Constraints[i].Restriction < minB
            {
                minB = Constraints[i].Restriction
                leaveBasis = i
            }
        }
        
        let auxLPP = LPP(objFunc: auxOF, constraints: auxCS)
        let auxD = Dictionary(LPP: auxLPP)
        auxD.display(withAnalysis: false)
        auxD.recalculate(enterIdx: 0, leaveIdx: leaveBasis)
        
        while !isSolutionFound(dictionary: auxD)
        {
            auxD.display(withAnalysis: true, preferToLeave: 1)
            auxD.improve(preferToLeave: 1)
        }
        
        auxD.display(withAnalysis: true, preferToLeave: 1)
        let count = auxD.basicVars.count
        var bb: [Int] = Array(repeating: 0, count: count)
        var cc : [[Double]] = Array(repeating: Array(repeating: 0, count: count + 1), count: auxLPP.Constraints.count)
        var ss: [Int] = Array(repeating: 0, count: auxLPP.Constraints.count)
        
        for i in 0 ..< count
        {
            bb[i] = auxD.basicVars[i]
            for j in 0 ..< auxLPP.Constraints.count
            {
                cc[j][i+1] = auxD.c[j][i+1]
            }
        }
        
        for j in 0 ..< auxLPP.Constraints.count
        {
            cc[j][0] = auxD.c[j][0]; ss[j] = auxD.slackVars[j];
        }
        auxD.a = Array(repeating: 0.0, count: count - 1)
        auxD.basicVars = Array(repeating: 0, count: count - 1)
        auxD.slackVars = Array(repeating: 0, count: count - 1)
        auxD.c = Array(repeating: Array(repeating: 0.0, count: count), count: auxLPP.Constraints.count)
        for i in 0 ..< auxLPP.Constraints.count
        {
            auxD.c[i][0] = cc[i][0]
            var j = 1
            while ( bb[j - 1] != 1){auxD.c[i][j] = cc[i][j]; j += 1; }
            while (j < bb.count) { j += 1; auxD.c[i][j - 1] = cc[i][j]; }
            auxD.slackVars[i] = ss[i] - 1;
        }
        
        var k = 0
        while (bb[k] != 1) { auxD.basicVars[k] = bb[k] - 1; k += 1; }
        k += 1
        while (k < bb.count) { auxD.basicVars[k - 1] = bb[k] - 1; k += 1; }
        
        auxD.z0 = 0;
        
        for i in 0 ..< ObjFunc.Coefficients.count
        {
            for j in 0 ..< auxD.slackVars.count
            {
                auxD.z0 += ObjFunc.Coefficients[i] * auxD.c[j][0]
                for m in 0 ..< ObjFunc.Coefficients.count
                {
                    auxD.a[m] += ObjFunc.Coefficients[i] * auxD.c[j][m+1]
                }
            }
        }
        
        auxD.display(withAnalysis: false)
        
        print()
        
        return auxD
        
    }
    
    
}
