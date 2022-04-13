//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 13/04/2022.
//

import SwiftUI

extension View {
    func textFieldAlert(title: String, message: String, hintText: String, primaryTitle: String, secondaryTitle: String, primaryAction: @escaping (String)->(), secondaryAction: @escaping ()->()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { field in
            field.placeholder = title
        }
        
        alert.addAction(.init(title: secondaryTitle, style: .cancel, handler: { _ in
            secondaryAction()
        }))
        
        alert.addAction(.init(title: primaryTitle, style: .default, handler: { _ in
            if let text = alert.textFields?[0].text {
                primaryAction(text)
            } else {
                primaryAction("")
            }
        }))
        
        rootController().present(alert, animated: true, completion: nil)
    }
    
    func rootController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .init() }
        
        guard let root = screen.windows.first?.rootViewController else { return .init() }
        
        return root
    }
}
