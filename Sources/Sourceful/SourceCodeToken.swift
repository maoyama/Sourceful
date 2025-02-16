//
//  SourceCodeToken.swift
//  SourceEditor
//
//  Created by Louis D'hauwe on 24/07/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public enum SourceCodeTokenType {
	case plain
	case number
	case string
	case identifier
	case keyword
	case comment
	case editorPlaceholder
}

protocol SourceCodeToken: Token {
	
	var type: SourceCodeTokenType { get }
	
}

extension SourceCodeToken {
	
	var isEditorPlaceholder: Bool {
		return type == .editorPlaceholder
	}
	
	var isPlain: Bool {
		return type == .plain
	}
	
}

struct SimpleSourceCodeToken: SourceCodeToken {
	
	let type: SourceCodeTokenType
	
	let range: Range<String.Index>
	
}

public enum GitDiffOutputChunkTokenType: String, CaseIterable {
    case header = "@"
    case removed = "-"
    case added = "+"
    case unchanged = " "
}

struct GitDiffOutputChunkToken: Token {
    var isEditorPlaceholder = false
    var isPlain: Bool {
        type == .unchanged
    }
    var range: Range<String.Index>
    var type: GitDiffOutputChunkTokenType
}
