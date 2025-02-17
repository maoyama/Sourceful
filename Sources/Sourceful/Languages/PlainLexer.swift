//
//  PlainLexer.swift
//  Sourceful
//
//  Created by Makoto Aoyama on 2025/02/17.
//

import Foundation

final public class PlainLexer: Lexer {
    public init() {}

    public func getSavannaTokens(input: String) -> [any Token] {
        generateGitDiffOutputTokens(source: input)
    }
}
