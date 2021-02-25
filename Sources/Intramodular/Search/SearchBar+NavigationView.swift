//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
fileprivate struct _NavigationSearchBarConfigurator<SearchResultsContent: View>: UIViewControllerRepresentable  {
    let searchBar: SearchBar
    let searchResultsContent: () -> SearchResultsContent
    
    @Environment(\._hidesNavigationSearchBarWhenScrolling) var hidesSearchBarWhenScrolling: Bool?
    
    var automaticallyShowSearchBar: Bool? = false
    var hideNavigationBarDuringPresentation: Bool?
    var obscuresBackgroundDuringPresentation: Bool?
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        UIViewControllerType(coordinator: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.base = self
        context.coordinator.searchBarCoordinator.base = searchBar
        context.coordinator.uiViewController = uiViewController.navigationController?.topViewController
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(base: self, searchBarCoordinator: .init(base: searchBar))
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension _NavigationSearchBarConfigurator {
    class Coordinator: NSObject, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
        var base: _NavigationSearchBarConfigurator
        var searchBarCoordinator: SearchBar.Coordinator
        var searchController: UISearchController!
        
        weak var uiViewController: UIViewController? {
            didSet {
                if uiViewController == nil || uiViewController != oldValue {
                    oldValue?.searchController = nil
                }
                
                updateSearchController()
            }
        }
        
        init(
            base: _NavigationSearchBarConfigurator,
            searchBarCoordinator: SearchBar.Coordinator
        ) {
            self.base = base
            self.searchBarCoordinator = searchBarCoordinator
            
            super.init()
            
            initializeSearchController()
            updateSearchController()
        }
        
        func initializeSearchController() {
            let searchResultsController: UIViewController?
            let searchResultsContent = base.searchResultsContent()
            
            if searchResultsContent is EmptyView {
                searchResultsController = nil
            } else {
                searchResultsController = UIHostingController<SearchResultsContent>(rootView: base.searchResultsContent())
            }
            
            searchController = UISearchController(searchResultsController: searchResultsController)
            searchController.definesPresentationContext = true
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.delegate = self
            searchController.searchResultsUpdater = self
        }
        
        func updateSearchController() {
            guard let uiViewController = uiViewController else {
                return
            }
            
            if uiViewController.searchController !== searchController {
                uiViewController.searchController = searchController
            }
            
            if let obscuresBackgroundDuringPresentation = base.obscuresBackgroundDuringPresentation {
                searchController.obscuresBackgroundDuringPresentation = obscuresBackgroundDuringPresentation
            } else {
                searchController.obscuresBackgroundDuringPresentation = false
            }
            
            if let hideNavigationBarDuringPresentation = base.hideNavigationBarDuringPresentation {
                searchController.hidesNavigationBarDuringPresentation = hideNavigationBarDuringPresentation
            }
            
            (searchController.searchResultsController as? UIHostingController<SearchResultsContent>)?.rootView = base.searchResultsContent()
            
            if let hidesSearchBarWhenScrolling = base.hidesSearchBarWhenScrolling {
                uiViewController.hidesSearchBarWhenScrolling = hidesSearchBarWhenScrolling
            }
            
            if let automaticallyShowSearchBar = base.automaticallyShowSearchBar, automaticallyShowSearchBar {
                uiViewController.sizeToFitSearchBar()
            }
        }
        
        // MARK: - UISearchBarDelegate
        
        public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBarCoordinator.searchBarTextDidBeginEditing(searchBar)
        }
        
        public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            searchBarCoordinator.searchBar(searchBar, textDidChange: searchText)
        }
        
        public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBarCoordinator.searchBarTextDidEndEditing(searchBar)
        }
        
        public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBarCoordinator.searchBarCancelButtonClicked(searchBar)
            
            searchController.isActive = false
        }
        
        public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBarCoordinator.searchBarSearchButtonClicked(searchBar)
            
            searchController.isActive = false
        }
        
        // MARK: UISearchControllerDelegate
        
        func willPresentSearchController(_ searchController: UISearchController) {
            
        }
        
        func didPresentSearchController(_ searchController: UISearchController) {
            
        }
        
        func willDismissSearchController(_ searchController: UISearchController) {
            
        }
        
        func didDismissSearchController(_ searchController: UISearchController) {
            
        }
        
        // MARK: UISearchResultsUpdating
        
        func updateSearchResults(for searchController: UISearchController) {
            
        }
    }
    
    class UIViewControllerType: UIViewController {
        weak var coordinator: Coordinator?
        
        init(coordinator: Coordinator?) {
            self.coordinator = coordinator
            
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            
            coordinator?.uiViewController = navigationController?.topViewController
        }
        
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            
            coordinator?.uiViewController = navigationController?.topViewController
        }
        
        override func viewWillAppear(_ animated: Bool) {
            coordinator?.uiViewController = navigationController?.topViewController
        }
    }
}

// MARK: - API -

extension View {
    /// Sets the navigation search bar for this view.
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    public func navigationSearchBar(_ searchBar: () -> SearchBar) -> some View {
        background(_NavigationSearchBarConfigurator(searchBar: searchBar(), searchResultsContent: { EmptyView() }))
    }
    
    /// Hides the integrated search bar when scrolling any underlying content.
    public func navigationSearchBarHiddenWhenScrolling(_ hidesSearchBarWhenScrolling: Bool) -> some View {
        environment(\._hidesNavigationSearchBarWhenScrolling, hidesSearchBarWhenScrolling)
    }
}

// MARK: - Auxiliary Implementation -

extension EnvironmentValues {
    final class _HidesNavigationSearchBarWhenScrolling: DefaultEnvironmentKey<Bool> {
        
    }
    
    var _hidesNavigationSearchBarWhenScrolling: Bool? {
        get {
            self[_HidesNavigationSearchBarWhenScrolling]
        } set {
            self[_HidesNavigationSearchBarWhenScrolling] = newValue
        }
    }
}

// MARK: - Helpers -

private extension UIViewController {
    var searchController: UISearchController? {
        get {
            navigationItem.searchController
        } set {
            navigationItem.searchController = newValue
        }
    }
    
    var hidesSearchBarWhenScrolling: Bool {
        get {
            navigationItem.hidesSearchBarWhenScrolling
        } set {
            navigationItem.hidesSearchBarWhenScrolling = newValue
        }
    }
    
    func sizeToFitSearchBar() {
        navigationController?.navigationBar.sizeToFit()
    }
}

#endif
