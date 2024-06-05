//
//  HomeViewModel.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var category: Category = .init()

    init() {
        loadData()
    }

    func loadData() {
        loadVideos()
    }

    private func loadVideos() {
        if let fileURL = Bundle.main.url(forResource: "media", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)
                let decodedData = try JSONDecoder().decode(Category.self, from: data)
                category = decodedData
            } catch {
                print("AAA error loading json data: \(error.localizedDescription)")
            }
        } else {
            print("AAA file not found")
        }
    }
}
