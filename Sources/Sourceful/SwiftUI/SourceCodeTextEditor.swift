//
//  SourceCodeTextEditor.swift
//
//  Created by Andrew Eades on 14/08/2020.
//

import Foundation

#if canImport(SwiftUI)

import SwiftUI

#if os(macOS)

public typealias _ViewRepresentable = NSViewRepresentable

#endif

#if os(iOS)

public typealias _ViewRepresentable = UIViewRepresentable

#endif


public struct SourceCodeTextEditor: _ViewRepresentable {
    
    public struct Customization {
        var didChangeText: (SourceCodeTextEditor) -> Void
        var insertionPointColor: () -> Sourceful.Color
        var lexerForSource: (String) -> Lexer
        var textViewDidBeginEditing: (SourceCodeTextEditor) -> Void
        var theme: () -> SourceCodeTheme
        
        /// Creates a **Customization** to pass into the *init()* of a **SourceCodeTextEditor**.
        ///
        /// - Parameters:
        ///     - didChangeText: A SyntaxTextView delegate action.
        ///     - lexerForSource: The lexer to use (default: SwiftLexer()).
        ///     - insertionPointColor: To customize color of insertion point caret (default: .white).
        ///     - textViewDidBeginEditing: A SyntaxTextView delegate action.
        ///     - theme: Custom theme (default: DefaultSourceCodeTheme()).
        public init(
            didChangeText: @escaping (SourceCodeTextEditor) -> Void,
            insertionPointColor: @escaping () -> Sourceful.Color,
            lexerForSource: @escaping (String) -> Lexer,
            textViewDidBeginEditing: @escaping (SourceCodeTextEditor) -> Void,
            theme: @escaping () -> SourceCodeTheme
        ) {
            self.didChangeText = didChangeText
            self.insertionPointColor = insertionPointColor
            self.lexerForSource = lexerForSource
            self.textViewDidBeginEditing = textViewDidBeginEditing
            self.theme = theme
        }
    }
    
    @Binding private var text: String
    @Binding private var lineNumbers: [String]
    private var shouldBecomeFirstResponder: Bool
    private var custom: Customization
    
    public init(
        text: Binding<String>,
        customization: Customization = Customization(
            didChangeText: {_ in },
            insertionPointColor: { Sourceful.Color.white },
            lexerForSource: { _ in SwiftLexer() },
            textViewDidBeginEditing: { _ in },
            theme: { DefaultSourceCodeTheme() }
        ),
        shouldBecomeFirstResponder: Bool = false,
        lineNumbers: Binding<[String]> = .constant([])
    ) {
        self._text = text
        self.custom = customization
        self.shouldBecomeFirstResponder = shouldBecomeFirstResponder
        self._lineNumbers = lineNumbers
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    #if os(iOS)
    public func makeUIView(context: Context) -> SyntaxTextView {
        let wrappedView = SyntaxTextView()
        wrappedView.delegate = context.coordinator
        wrappedView.theme = custom.theme()
        wrappedView.lineNumbers = lineNumbers
//        wrappedView.contentTextView.insertionPointColor = custom.insertionPointColor()
        
        context.coordinator.wrappedView = wrappedView
        context.coordinator.wrappedView.text = text
        
        return wrappedView
    }
    
    public func updateUIView(_ view: SyntaxTextView, context: Context) {
        if shouldBecomeFirstResponder {
            view.becomeFirstResponder()
        }
        view.text = text
    }
    #endif
    
    #if os(macOS)
    public func makeNSView(context: Context) -> SyntaxTextView {
        let wrappedView = SyntaxTextView()
        wrappedView.textView.isEditable = false
        wrappedView.delegate = context.coordinator
        wrappedView.theme = custom.theme()
        wrappedView.lineNumbers = lineNumbers
        wrappedView.contentTextView.insertionPointColor = custom.insertionPointColor()
        
        context.coordinator.wrappedView = wrappedView
        context.coordinator.wrappedView.text = text
        
        return wrappedView
    }
    
    public func updateNSView(_ view: SyntaxTextView, context: Context) {
        view.text = text
    }
    #endif

    public func sizeThatFits(_ proposal: ProposedViewSize, nsView: SyntaxTextView, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        return .init(width: width, height: fittingSize(for: nsView.contentTextView).height)
    }

    func fittingSize(for textView: NSTextView) -> NSSize {
        guard let textContainer = textView.textContainer,
              let layoutManager = textView.layoutManager else {
            return .zero
        }
        textContainer.containerSize = NSSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        layoutManager.glyphRange(for: textContainer)
        let neededHeight = layoutManager.usedRect(for: textContainer).height
        return NSSize(width: textView.bounds.width, height: neededHeight)
    }

}

extension SourceCodeTextEditor {
    
    public class Coordinator: SyntaxTextViewDelegate {
        let parent: SourceCodeTextEditor
        var wrappedView: SyntaxTextView!
        
        init(_ parent: SourceCodeTextEditor) {
            self.parent = parent
        }
        
        public func lexerForSource(_ source: String) -> Lexer {
            parent.custom.lexerForSource(source)
        }
        
        public func didChangeText(_ syntaxTextView: SyntaxTextView) {
            DispatchQueue.main.async {
                self.parent.text = syntaxTextView.text
            }
            
            // allow the client to decide on thread
            parent.custom.didChangeText(parent)
        }
        
        public func textViewDidBeginEditing(_ syntaxTextView: SyntaxTextView) {
            parent.custom.textViewDidBeginEditing(parent)
        }
    }
}

#endif

#Preview {
    @Previewable @State var text = "Hello world!\n\nHello world!\n"
    LazyVStack {
        Text(text)
        SourceCodeTextEditor(text: $text)
        SourceCodeTextEditor(text: $text)
        SourceCodeTextEditor(text: $text)
    }
}

#Preview("Custom line numbers") {
    @Previewable @State var text = "Hello world!\n\nHello world!\n"
    @Previewable @State var lineNumbers = ["111", "112", "113", "114"]
    @Previewable @State var lineNumbers2 = ["111", "112", "1134", ""]
    @Previewable @State var lineNumbers3 = ["111", "", "1134", ""]

    LazyVStack {
        Text(text)
        SourceCodeTextEditor(text: $text, lineNumbers: $lineNumbers)
        SourceCodeTextEditor(text: $text, lineNumbers: $lineNumbers2)
        SourceCodeTextEditor(text: $text, lineNumbers: $lineNumbers3)

    }
}

#Preview("line breaks are not working") {
    @Previewable @State var text = "Hello world! Hello world! Hello world! Hello world! Hello world!world!world!world!world!world!world!\nHello world!"
    LazyVStack {
        Text(text)
        SourceCodeTextEditor(text: $text)
    }
}
