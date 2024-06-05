//
//  Router.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import SwiftUI

class AnyIdentifiable: Identifiable {
    let destination: any Identifiable

    init(destination: any Identifiable) {
        self.destination = destination
    }
}

final class Router: ObservableObject {
    @Published var navPath = NavigationPath()
    @Published var presentedSheet: AnyIdentifiable?

    init() {}

    func presentSheet(destination: any Identifiable) {
        presentedSheet = AnyIdentifiable(destination: destination)
    }

    func navigate(to destination: any Hashable) {
        navPath.append(destination)
    }

    func navigateBack() {
        navPath.removeLast()
    }

    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
}
