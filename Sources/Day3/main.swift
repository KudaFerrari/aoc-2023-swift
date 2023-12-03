//
//  main.swift
//  
//
//  Created by Kennedy L on 03/12/23.
//

import Foundation
import InputFiles

//let schematics = Schematics(string: """
//......
//.12*..
//....9.
//""")
let schematics = Schematics(string: InputFiles.readInput("Day3"))

print("sum gear ratio:", schematics.sumGearRatio())
print("sum part numbers:", schematics.sumPartNumbers())

