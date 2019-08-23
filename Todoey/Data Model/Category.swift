//
//  Category.swift
//  Todoey
//
//  Created by Michael Granberry on 8/20/19.
//  Copyright © 2019 MGG. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
}
