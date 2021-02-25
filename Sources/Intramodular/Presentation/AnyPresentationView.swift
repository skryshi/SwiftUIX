//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct AnyPresentationView: View {
    public let base: _opaque_View
    
    private var environmentBuilder: EnvironmentBuilder
    
    public private(set) var name: ViewName
    public private(set) var modalPresentationStyle: ModalPresentationStyle = .automatic
    public private(set) var hidesBottomBarWhenPushed: Bool = false
    
    public var body: some View {
        base.eraseToAnyView().mergeEnvironmentBuilder(environmentBuilder)
    }
    
    public init<V: View>(_ view: V) {
        if let view = view as? AnyPresentationView {
            self = view
        } else {
            self.base = (view as? _opaque_View) ?? view.eraseToAnyView()
            self.environmentBuilder = .init()
        }
        
        self.name = ViewName()
    }
}

// MARK: - Protocol Conformances -

extension AnyPresentationView: _opaque_View {
    public func _opaque_getViewName() -> ViewName? {
        name
    }
}

extension AnyPresentationView: ModalPresentationView {
    public var preferredSourceViewName: ViewName? {
        (base as? _opaque_ModalPresentationView)?.preferredSourceViewName ?? name
    }

    public var presentationStyle: ModalPresentationStyle {
        modalPresentationStyle
    }
}

// MARK: - API -

extension AnyPresentationView {
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> Self {
        then({ $0.environmentBuilder.merge(builder) })
    }
    
    public mutating func mergeEnvironmentBuilderInPlace(_ builder: EnvironmentBuilder) {
        self = mergeEnvironmentBuilder(builder)
    }
}

extension AnyPresentationView {
    public func name(_ name: ViewName) -> Self {
        then({ $0.name = name })
    }
}

extension AnyPresentationView {
    public func modalPresentationStyle(_ style: ModalPresentationStyle) -> Self {
        then({ $0.modalPresentationStyle = style })
    }
}

extension AnyPresentationView {
    public func hidesBottomBarWhenPushed(_ hidesBottomBarWhenPushed: Bool) -> Self {
        then({ $0.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed })
    }
}
