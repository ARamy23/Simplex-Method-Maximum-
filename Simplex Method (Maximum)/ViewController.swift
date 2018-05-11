//
//  ViewController.swift
//  Simplex Method (Maximum)
//
//  Created by Ahmed Ramy on 5/4/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var objectiveFunctionTextField: UITextField!
    @IBOutlet weak var solutionLogTextView: UITextView!
    
    @IBOutlet weak var constraintsTableView: UITableView!
    var constraints : [String] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        constraintsTableView.register(nib, forCellReuseIdentifier: "TableViewCell")
    }
    
    @IBAction func didTapCompute(_ sender: Any)
    {
        view.endEditing(true)
        let objectiveFunction = extractObjFunc()
        constraints.removeAll()
        for cell in constraintsTableView.visibleCells as! Array<TableViewCell>
        {
            let equation = cell.constraintEquationTextField.text
            constraints.append(equation!)
        }

        let cons = constraints.map({extractConstraint(equation: $0)})
//        var objFunc = ObjectiveFunction(coefficients: [2.5,3.2])
//        var cons = [Constraint]()
//        let constraint1 = Constraint(coefficients: [20,60], restriction: 1500)
//        let constraint2 = Constraint(coefficients: [70,60], restriction: 2100)
//        let constraint3 = Constraint(coefficients: [12,4], restriction: 300)
//        cons.append(constraint1)
//        cons.append(constraint2)
//        cons.append(constraint3)
        let lpp = LPP(objFunc: objectiveFunction!, constraints: cons as! [Constraint] )
        solutionLogTextView.text = lpp.solve().log
        
    }
    
    @IBAction func didTapAddConstraint(_ sender: Any)
    {
        constraints.append("")
        constraintsTableView.beginUpdates()
        let indexPath = IndexPath(row: constraints.count - 1, section: 0)
        constraintsTableView.insertRows(at: [indexPath], with: .automatic)
        constraintsTableView.endUpdates()
    }
    
    private func  extractObjFunc() -> ObjectiveFunction?
    {
        guard let coeffs = objectiveFunctionTextField.text?.removeWhitespace().lowercased().components(separatedBy: "+").compactMap({Double($0.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").components(separatedBy: "x").first!)})  else {print("error with coeffs of Objective Function"); return nil;}
        print(coeffs.debugDescription)
        let objFunc = ObjectiveFunction(coefficients: coeffs)
        
        return objFunc
    }
    
    private func extractConstraint(equation: String) -> Constraint?
    {
        let restriction = Double(equation.removeWhitespace().lowercased().components(separatedBy: "=")[1])
        let coeffs = equation.removeWhitespace().lowercased().components(separatedBy: "+").compactMap({Double($0.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").components(separatedBy: "x").first!)})
        return Constraint(coefficients: coeffs, restriction: restriction!)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return constraints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = constraintsTableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        return cell
    }
    
    
}

extension String {
    
    func removeWhitespace() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}



