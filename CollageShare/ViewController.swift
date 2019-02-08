//
//  ViewController.swift
//  CollageShare
//
//  Created by user140592 on 2/7/19.
//  Copyright © 2019 talspektor. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDropInteractionDelegate, UIDragInteractionDelegate {
   
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        let touchPoint = session.location(in: self.view)
        if let touchedImageView = self.view.hitTest(touchPoint, with: nil) as? UIImageView {
            
            let touchedImage =  touchedImageView.image
            
            let itemProvider = NSItemProvider(object: touchedImage!)
            
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = touchedImageView
            return [dragItem]
        }
        
        
        return []
    }
    
    // Remove view after draging
    func dragInteraction(_ interaction: UIDragInteraction, willAnimateLiftWith animator: UIDragAnimating, session: UIDragSession) {
        session.items.forEach { (dragItem) in
            if let touchedImageView = dragItem.localObject as? UIView {
                touchedImageView.removeFromSuperview()
            }
        }
    }
    
    // Handle cancel
    func dragInteraction(_ interaction: UIDragInteraction, item: UIDragItem, willAnimateCancelWith animator: UIDragAnimating) {
        self.view.addSubview(item.localObject as! UIView)
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        return UITargetedDragPreview(view: item.localObject as! UIView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.title = "Collage Sharing"
        // Share button.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        view.addInteraction(UIDropInteraction(delegate: self))
        view.addInteraction(UIDragInteraction(delegate: self))
    }
    
    @objc private func handleShare() {
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        
        let activityViewController = UIActivityViewController(activityItems: [image, "Sharing this nice image"], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(activityViewController, animated: true, completion: nil)
        
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for dragItemd in session.items {
            dragItemd.itemProvider.loadObject(ofClass: UIImage.self) { (obj, err) in
                
                if let err = err {
                    print("Failed to load our dragged item:", err)
                    return
                }
                
                guard let draggedImage = obj as? UIImage else { return }
                
                DispatchQueue.main.async {
                    let imageView = UIImageView(image: draggedImage)
                    imageView.isUserInteractionEnabled = true
                    imageView.layer.borderWidth = 4
                    imageView.layer.borderColor = UIColor.black.cgColor
                    imageView.layer.shadowRadius = 5
                    imageView.layer.shadowOpacity = 0.3
                    self.view.addSubview(imageView)
                    imageView.frame = CGRect(x: 0, y: 0, width: draggedImage.size.width, height: draggedImage.size.height)
                    
                    let centerPoint = session.location(in: self.view)
                    imageView.center = centerPoint
                }
            }
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }


}

