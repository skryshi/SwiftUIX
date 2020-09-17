//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A utility view modifier that allows for dynamic navigation based on some arbitrary selection value.
fileprivate struct SelectionNavigator<Selection, Destination: View>: ViewModifier {
    private let selection: Binding<Selection?>
    private let destination: (Selection) -> Destination
    private let onDismiss: (() -> Void)?
    
    public init(
        selection: Binding<Selection?>,
        onDismiss: (() -> Void)?,
        @ViewBuilder destination: @escaping (Selection) -> Destination
    ) {
        self.selection = selection
        self.onDismiss = onDismiss
        self.destination = destination
    }
    
    private func setIsActive(_ isActive: Bool) {
        if !isActive {
            if selection.wrappedValue != nil {
                selection.wrappedValue = nil
                onDismiss?()
            }
        } else if selection.wrappedValue == nil {
            fatalError()
        }
    }
    
    private var isActive: Binding<Bool> {
        .init(
            get: { self.selection.wrappedValue != nil },
            set: setIsActive
        )
    }
    
    public func body(content: Content) -> some View {
        content.background(
            NavigationLink(
                destination: LazyView {
                    self.destination(self.selection.wrappedValue!)
                },
                isActive: isActive,
                label: { ZeroSizeView() }
            )
        )
    }
}

// MARK: - API -

extension View {
    public func navigate<Destination: View>(
        to destination: Destination,
        isActive: Binding<Bool>,
        onDismiss: (() -> ())? = nil
    ) -> some View {
        background(
            NavigationLink(
                destination: destination,
                isActive: isActive,
                label: { ZeroSizeView() }
            )
        )
    }
    
    public func navigate<Destination: View>(
        isActive: Binding<Bool>,
        onDismiss: (() -> ())? = nil,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        navigate(to: destination(), isActive: isActive, onDismiss: onDismiss)
    }
}

extension View {
    /// Adds a destination to present when this view is pressed.
    public func onPress<Destination: View>(
        navigateTo destination: Destination,
        onDismiss: (() -> ())? = nil
    ) -> some View {
        modifier(NavigateOnPress(destination: destination, onDismiss: onDismiss))
    }
    
    /// Adds a destination to present when this view is pressed.
    public func onPress<Destination: View>(
        navigateTo destination: Destination,
        isActive: Binding<Bool>,
        onDismiss: (() -> ())? = nil
    ) -> some View {
        modifier(NavigateOnPress(destination: destination, isActive: isActive, onDismiss: onDismiss))
    }
}

extension View {
    @available(*, deprecated, message: "This implementation is unreliable.")
    public func navigate<Selection, Destination: View>(
        selection: Binding<Selection?>,
        onDismiss: (() -> ())? = nil,
        @ViewBuilder destination: @escaping (Selection) -> Destination
    ) -> some View {
        modifier(SelectionNavigator(
            selection: selection,
            onDismiss: onDismiss,
            destination: destination
        ))
    }
}

// MARK: - Auxiliary Implementation -

fileprivate struct NavigateOnPress<Destination: View>: ViewModifier {
    let destination: Destination
    let isActive: Binding<Bool>?
    let onDismiss: (() -> Void)?
    
    @State var _internal_isActive: Bool = false
    
    init(
        destination: Destination,
        isActive: Binding<Bool>? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.destination = destination
        self.isActive = isActive
        self.onDismiss = onDismiss
    }
    
    func body(content: Content) -> some View {
        Button(toggle: isActive ?? $_internal_isActive) {
            content.contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            NavigationLink(
                destination: destination,
                isActive: isActive ?? $_internal_isActive,
                label: { EmptyView() }
            )
            .hidden()
        )
    }
}
