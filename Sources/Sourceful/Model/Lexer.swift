//
//  Lexer.swift
//  SavannaKit iOS
//
//  Created by Louis D'hauwe on 04/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public protocol Lexer {
	
	func getSavannaTokens(input: String) -> [Token]
	
}

extension Lexer {
    public func generateGitDiffOutputTokens(source: String) -> [Token] {
        var tokens = [GitDiffOutputChunkToken]()

        source.enumerateSubstrings(in: source.startIndex..<source.endIndex, options: [.byLines]) { (line, range, _, _) in
            GitDiffOutputChunkTokenType.allCases.forEach { type in
                if line?.hasPrefix(type.rawValue) == true {
                    tokens.append(.init(range: range, type: type))
                }
            }
        }
        return tokens
    }

}
