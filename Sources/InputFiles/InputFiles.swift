//
//  InputFiles.swift
//  
//
//  Created by Kennedy L on 03/12/23.
//

import Foundation


public func readInput(_ fileName: String) -> String {
    guard let url = Bundle.module.url(forResource: "Input/\(fileName)", withExtension: nil)
    else { fatalError("expected input file: \(fileName)") }
    
    do {
        guard let result = String(data: try Data(contentsOf: url), encoding: .utf8)
        else { fatalError("invalid input file") }
        return result
    } catch {
        print(error.localizedDescription)
    }
    fatalError("Could not read input file")
}
