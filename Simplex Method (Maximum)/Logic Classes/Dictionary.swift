//
//  Dictionary.swift
//  ARSimplexMethod
//
//  Created by Ahmed Ramy on 5/4/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import Foundation

class Dictionary
{
    public var c : [[Double]]
    public var a : [Double]
    public var z0 : Double
    
    public var basicVars : [Int]
    public var slackVars: [Int]
    public var log = ""
    
    init(LPP: LPP)
    {
        z0 = 0
        self.a = Array(repeating: 0, count: LPP.ObjFunc.VariablesCount)
        for i in 0 ..< LPP.ObjFunc.VariablesCount
        {
            a[i] = LPP.ObjFunc.Coefficients[i]
        }
        
        self.basicVars = Array(repeating: 0, count: LPP.ObjFunc.VariablesCount)
        for i in 0 ..< LPP.ObjFunc.VariablesCount
        {
            basicVars[i] = i + 1
        }
        
        self.slackVars = Array(repeating: 0, count: LPP.ObjFunc.VariablesCount)
        for i in 0 ..< LPP.ObjFunc.VariablesCount
        {
            slackVars[i] = LPP.ObjFunc.VariablesCount + i + 1
        }
        
        self.c = Array(repeating: Array(repeating: 0, count: LPP.ObjFunc.VariablesCount + 1), count: LPP.Constraints.count)

        
        for i in 0 ..< LPP.Constraints.count
        {
            c[i][0] = LPP.Constraints[i].Restriction
            for j in 1 ..< LPP.ObjFunc.VariablesCount + 1
            {
                c[i][j] = -LPP.Constraints[i].Coefficients[j-1]
            }
        }
    }
    
    public func isFeasible() -> Bool
    {
        for i in 0 ..< slackVars.count
        {
            if c[i][0] < 0 {return false}
        }

        return true
    }
    
    public func entersBasis() -> Int
    {
        var n = -1
        var maxA = self.a[0]
        if maxA > 0 {n = 0}
        
        for i in 0 ..< a.count
        {
            if (a[i] > 0 && a[i] > maxA) { maxA = a[i]; n = i; }
        }
        
        return n
    }
    
    private func leavesBasis(enterIdx: Int, preferToLeave: Int = -1 ) -> Int
    {
        if (enterIdx == -1) {return -1}
        
        var idxPTL = -1
        var n = -1
        var dc : [Double] = Array(repeating: 0, count: slackVars.count)
        for i in 0 ..< dc.count
        {
            if (preferToLeave != -1 && slackVars[i] == preferToLeave) {idxPTL = i}
            if (c[i][ 1 + enterIdx] < 0)
            {dc[i] = c[i][0] / c[i][1 + enterIdx]}
            else
            {dc[i] = -(Double.infinity)}
        }
        
        var maxDC = dc[0]
        if maxDC > -(Double.infinity) {n = 0}
        
        for i in 0 ..< dc.count
        {
            if (dc[i] <= 0 && dc[i] >= maxDC)
            {
                maxDC = dc[i]
                n = i
                if (idxPTL != -1 && dc[idxPTL] == maxDC){ n = idxPTL}
            }
        }
        return n
    }
    
    public func improve(preferToLeave: Int = -1)
    {
        let eb = entersBasis()
        if eb != -1
        {
            let lb = leavesBasis(enterIdx: eb, preferToLeave: preferToLeave)
            if lb != -1 {recalculate(enterIdx: eb, leaveIdx: lb)}
        }
    }
    
    public func display(withAnalysis: Bool = true, preferToLeave: Int = -1)
    {
        print()
        print("Dictionary for LPP:")
        
        log += "\nDictionary for LPP:\n"
        
        for i in 0 ..< slackVars.count
        {
            print("x\(slackVars[i]) = \(c[i][0])", separator: "")
            log += "x\(slackVars[i]) = \(c[i][0])"
            for j in 0 ..< a.count
            {
                print("\(c[i][j+1])*x\(basicVars[j])", separator: "")
                log += "\(c[i][j+1])*x\(basicVars[j])"

            }
            print()
            log += "\n"
        }
        
        print("z = \(z0)", separator: "")
        log += "z = \(z0)"
        for j in 0 ..< a.count
        {
            print("+ (\(a[j])*x\(basicVars[j]))")
            log += "+ (\(a[j])*x\(basicVars[j]))\n"
        }
        print()
        log += "\n"
        
        if (withAnalysis)
        {
            let eb = entersBasis()
            if (eb == -1)
            {
                print("No variables to enter basis - solution is found.")
                print("The optimal value of objective function is \(z0).")
                print("The optimal solution is:")
                log += "No variables to enter basis - solution is found.\n"
                log += "The optimal value of objective function is \(z0).\n"
                log += "The optimal solution is:\n"
                for i in 0 ..< basicVars.count
                {
                    print("x\(basicVars[i]) = 0")
                    log += "x\(basicVars[i]) = 0\n"
                    
                }
                for i in 0 ..< slackVars.count
                {
                    print("x\(slackVars[i]) = \(c[i][0])")
                    
                    log += "x\(slackVars[i]) = \(c[i][0])\n"
                }
            }
            else
            {
                print("Enters basis: x\(basicVars[eb])")
                log += "Enters basis: x\(basicVars[eb])\n"
                if (leavesBasis(enterIdx: eb) == -1)
                {
                    print("No variables to leave basis.")
                    
                    log += "No variables to leave basis.\n"
                    
                }
                else
                {
                    print("Leaves basis: x\(slackVars[leavesBasis(enterIdx: eb, preferToLeave: preferToLeave)])")
                    log += "Leaves basis: x\(slackVars[leavesBasis(enterIdx: eb, preferToLeave: preferToLeave)])\n"
                }
            }
            print()
            log += "\n"
        }
        
    }
    
    public func recalculate(enterIdx: Int, leaveIdx: Int)
    {
        c[leaveIdx][0] = -c[leaveIdx][0] / c[leaveIdx][enterIdx + 1]
        c[leaveIdx][enterIdx + 1] = 1 / c[leaveIdx][enterIdx + 1]
        
        for j in 0 ..< basicVars.count
        {
            if j != enterIdx
            {
                c[leaveIdx][j + 1] = -c[leaveIdx][j + 1] * c[leaveIdx][enterIdx + 1]
            }
        }
        
        for i in 0 ..< slackVars.count
        {
            if (i != leaveIdx)
            {
                let oldC = c[i][enterIdx + 1];
                c[i][0] = c[i][0] + c[i][enterIdx + 1] * c[leaveIdx][0];
                c[i][enterIdx + 1] = c[i][enterIdx + 1] * c[leaveIdx][enterIdx + 1];
                for j in 0 ..< basicVars.count
                {if (j != enterIdx) {c[i][j + 1] = c[i][j + 1] + oldC * c[leaveIdx][j + 1]}}
                // Recalculating coefficients for objective function
                z0 = z0 + a[enterIdx] * c[leaveIdx][0];
                let oldA = a[enterIdx];
                a[enterIdx] = a[enterIdx] * c[leaveIdx][enterIdx + 1];
                for j in 0 ..< basicVars.count
                {if (j != enterIdx) {a[j] = a[j] + oldA * c[leaveIdx][j + 1]}}
                // Swaping names of basic and slack variables
                let valueToSwap = basicVars[enterIdx];
                basicVars[enterIdx] = slackVars[leaveIdx]; slackVars[leaveIdx] = valueToSwap;
            }
        }
    }
}
