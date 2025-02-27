//
//  TextViewWrapperView.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 17/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif

#if os(macOS)
	
	class TextViewWrapperView: _View {
		
		override func hitTest(_ point: NSPoint) -> NSView? {
			// Disable interaction, so we're not blocking the text view.
			return nil
		}
		
		override func layout() {
			super.layout()
			
			self.setNeedsDisplay(self.bounds)
		}
		
		override func resize(withOldSuperviewSize oldSize: NSSize) {
			super.resize(withOldSuperviewSize: oldSize)
			
			self.textView?.invalidateCachedParagraphs()

			self.setNeedsDisplay(self.bounds)
			
		}
		
		var textView: InnerTextView?
		
		override public func draw(_ rect: CGRect) {
			
			guard let textView = textView else {
				return
			}
			
			guard let theme = textView.theme else {
				super.draw(rect)
				textView.hideGutter()
				return
			}
			
			if theme.lineNumbersStyle == nil {

				textView.hideGutter()
				
				let gutterRect = CGRect(x: 0, y: rect.minY, width: textView.gutterWidth, height: rect.height)
				let path = BezierPath(rect: gutterRect)
				path.fill()
				
			} else {
				var paragraphs: [Paragraph]
			
				if let cached = textView.cachedParagraphs {
					
					paragraphs = cached
					
				} else {
					
					paragraphs = generateParagraphs(for: textView, lineNumbers: textView.lineNumbers, flipRects: true)
					textView.cachedParagraphs = paragraphs
					
				}


				theme.gutterStyle.backgroundColor.setFill()
			
				let gutterRect = CGRect(x: 0, y: rect.minY, width: textView.gutterWidth, height: rect.height)

				let path = BezierPath(rect: gutterRect)
				path.fill()
			
				drawLineNumbers(paragraphs, in: rect, for: textView)
			
			}

		}
		
	}
	
#endif
