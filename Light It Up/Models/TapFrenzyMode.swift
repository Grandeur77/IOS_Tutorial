//
//  TapFrenzyMode.swift
//  Light It Up
//
//  Created by Mileesha Fernando on 2026-07-02.
//
import Foundation

enum TapFrenzyMode: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case `default` = "Default"
    case combo = "Combo System"
    case trapColour = "Trap Colour"
    case moving = "Moving Target"
    case shrinking = "Shrinking Button"
    case burst = "Bonus Burst"
}
