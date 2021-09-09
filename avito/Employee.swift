//
//  Employee.swift
//  avito
//
//  Created by Yaroslav Fomenko on 09.09.2021.
//

import Foundation

struct Employee: Codable {
    var name: String
    var phone: String
    var skills: [String]
}

struct Employees {
    var employees: [Employee]
}
