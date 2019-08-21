//
//  Double+Extension.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 21.05.18.
//  Copyright © 2018 Paul Neuhold. All rights reserved.
//
import Foundation

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
