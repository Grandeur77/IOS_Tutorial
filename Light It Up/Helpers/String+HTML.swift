//
//  String+HTML.swift
//  Light It Up
//
//  Created by Mileesha Fernando on 2026-07-02.
//
import Foundation

extension String {
    /// Decodes common HTML entities returned by the trivia database API.
    var htmlDecoded: String {
        var decoded = self
        let entities = [
            "&quot;": "\"",
            "&#039;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&ldquo;": "\"",
            "&rdquo;": "\"",
            "&rsquo;": "'",
            "&lsquo;": "'",
            "&ndash;": "–",
            "&mdash;": "—",
            "&eacute;": "é",
            "&Oacute;": "Ó",
            "&deg;": "°",
            "&micro;": "µ",
            "&trade;": "™"
        ]
        for (entity, character) in entities {
            decoded = decoded.replacingOccurrences(of: entity, with: character)
        }
        return decoded
    }
}

