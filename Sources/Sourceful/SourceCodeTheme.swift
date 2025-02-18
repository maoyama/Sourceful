//
//  SourceCodeTheme.swift
//  SourceEditor
//
//  Created by Louis D'hauwe on 24/07/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public protocol SourceCodeTheme: SyntaxColorTheme {

    func color(for syntaxColorType: SourceCodeTokenType) -> Color
    func color(for diffType: GitDiffOutputChunkTokenType) -> Color?
    func backGroundColor(for diffType: GitDiffOutputChunkTokenType) -> Color?

}

extension SourceCodeTheme {
	
	public func globalAttributes() -> [NSAttributedString.Key: Any] {
		
		var attributes = [NSAttributedString.Key: Any]()
		
		attributes[.font] = font
        attributes[.foregroundColor] = color(for: .plain)
		
		return attributes
	}
	
	public func attributes(for token: Token) -> [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		
		if let token = token as? SimpleSourceCodeToken {
			attributes[.foregroundColor] = color(for: token.type)
		}
        if let token = token as? GitDiffOutputChunkToken {
            if let color = color(for: token.type) {
                attributes[.foregroundColor] = color
            }
            if let backgroundColor = backGroundColor(for: token.type) {
                attributes[.backgroundColor] = backgroundColor
            }
        }

		return attributes
	}

    public func color(for diffType: GitDiffOutputChunkTokenType) -> Color? { return nil }
    public func backGroundColor(for diffType: GitDiffOutputChunkTokenType) -> Color? { return nil }

}
