//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

struct _DynamicViewContentTraitValues {
    var onDelete: ((IndexSet) -> Void)? = nil
    var onMove: ((IndexSet, Int) -> Void)? = nil
}

// MARK: - Auxiliary Implementation -

struct _DynamicViewContentTraitValuesEnvironmentKey: EnvironmentKey {
    static let defaultValue = _DynamicViewContentTraitValues()
}

extension EnvironmentValues {
    var _dynamicViewContentTraitValues: _DynamicViewContentTraitValues {
        get {
            self[_DynamicViewContentTraitValuesEnvironmentKey]
        } set {
            self[_DynamicViewContentTraitValuesEnvironmentKey] = newValue
        }
    }
}
