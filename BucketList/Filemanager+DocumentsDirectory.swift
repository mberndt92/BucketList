//
//  Filemanager+DocumentsDirectory.swift
//  BucketList
//
//  Created by Maximilian Berndt on 2023/04/12.
//

import Foundation

extension FileManager {
    
    static var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveInDocuments<T: Encodable>(to filename: String, data: T) {
        let url = FileManager.documentsDirectory.appendingPathComponent(filename)
        do {
            let encodedData = try JSONEncoder().encode(data)
            try encodedData.write(to: url, options: .atomic)
        } catch {
            fatalError("Failed to save to documents directory")
        }
    }
    
    func loadFromDocuments<T: Decodable>(_ fileName: String) -> T {
        let url = FileManager.documentsDirectory.appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            
            return decodedData
        } catch {
            fatalError("Failed to load data from documents directory")
        }
    }
}
