//
//  Model.swift
//  avito
//
//  Created by Yaroslav Fomenko on 09.09.2021.
//

import Foundation
struct Employee: Codable {
    var name: String
    var phone_number: String
    var skills: [String]
}

struct Company: Codable {
    var name: String
    var employees: [Employee]
}

class CompanyData: Codable {
    var company: Company
}

