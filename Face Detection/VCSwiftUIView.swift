//
//  VCSwiftUIView.swift
//  Face Detection
//
//  Created by Sabin RanaBhat on 8/3/20.
//  Copyright © 2020 Sabin Ranabhat. All rights reserved.
//

import SwiftUI
import UIKit

struct VCSwiftUIView: UIViewControllerRepresentable {
    let storyboard: String
    let VC: String

  func makeUIViewController(context: UIViewControllerRepresentableContext<VCSwiftUIView>) -> ViewController {
    
    //Load the storyboard
    let loadedStoryboard = UIStoryboard(name: storyboard, bundle: nil)
    
    //Load the ViewController
     return loadedStoryboard.instantiateViewController(withIdentifier: VC) as! ViewController
    
  }
  
  func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<VCSwiftUIView>) {
  }
}
