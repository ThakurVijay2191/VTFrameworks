//
//  Validator.swift
//  VTFrameworks
//
//  Created by Nap Works on 14/04/24.
//

import Foundation

public struct Validator {
   public static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    public static func sayHello(){
        privateStruct.sayHello()
    }
}

fileprivate struct privateStruct{
    static func sayHello(){
        print("This is hello from private function.")
    }
}
