//
//  GameLevel.swift
//  Light It Up
//
//  Created by Mileesha Fernando on 2026-07-02.
//
import Foundation

enum GameLevel: Int, CaseIterable {
    case l1 = 1
    case l2 = 2
    case l3 = 3
    case l4 = 4
    
    var name: String {
        "L\(rawValue)"
    }
    
    var columns: Int {
        switch self {
        case .l1: return 3
        case .l2: return 2
        case .l3: return 3
        case .l4: return 3
        }
    }
    
    var totalCards: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }
    
    var litWindow: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }
    
    var numLitCards: Int {
        switch self {
        case .l4: return 2
        default: return 1
        }
    }
    
    static func level(for timeElapsed: Double) -> GameLevel {
        if timeElapsed < 15.0 {
            return .l1
        } else if timeElapsed < 30.0 {
            return .l2
        } else if timeElapsed < 45.0 {
            return .l3
        } else {
            return .l4
        }
    }
}
