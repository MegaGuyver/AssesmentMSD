//
//  BezierViewController.swift
//  assesment
//
//  Created by Fahad on 19/02/2023.
//

import UIKit

class BezierViewController: UIViewController {
    var imageView1 = UIImageView()
    var imageView2 = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

            let width: CGFloat = self.view.frame.size.width - 40
            let height: CGFloat = self.view.frame.size.width - 160


         imageView1 = UIImageView(frame: CGRect(x: self.view.frame.size.width/2 - width/2,
                                                  y: self.view.frame.size.height/2 - height/2,
                                                  width: width,
                                                  height: height))
        
        imageView2 = UIImageView(frame: CGRect(x: self.view.frame.size.width/2 - width/2,
                                                 y: self.view.frame.size.height/2 - height/2,
                                                 width: width,
                                                 height: height))
        
        
        // Add UIImages to View
        self.view.addSubview(imageView1)
        self.view.addSubview(imageView2)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        // Add First UIImageVIew
        imageView1 = imageView1.getCut(with: getFirstPath(view: imageView1))
        imageView1.backgroundColor = .yellow
        imageView1.addGestureRecognizer(tap)
        imageView1.isUserInteractionEnabled = true
        
        // Add second UIImageVIew
        imageView2 = imageView2.getCut(with: getSecondPath(view: imageView2))
        imageView2.backgroundColor = .green
        imageView2.addGestureRecognizer(tap)
        imageView2.isUserInteractionEnabled = true

    }
    
    func getFirstPath(view: UIView ) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: view.frame.width/3 * 2, y: 0.0))
        path.addLine(to: CGPoint(x: view.frame.width/3, y: view.frame.size.height))
        path.addLine(to: CGPoint(x: 0, y: view.frame.size.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        return path
    }
    
    func getSecondPath(view: UIView ) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: view.frame.width/3 * 2, y: 0.0))
        path.addLine(to: CGPoint(x: view.frame.width, y: 0.0))
        path.addLine(to: CGPoint(x: view.frame.width, y: view.frame.size.height))
        path.addLine(to: CGPoint(x: view.frame.width/3, y: view.frame.size.height))
        path.close()
        return path
    }
    
    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        let point = sender.location(in: imageView1)

        let shapeLayer = sender.view?.layer.mask as? CAShapeLayer
        let containsInRightSide =  (shapeLayer?.path?.contains(point))!
        
        // Can add choice in here to select from camera/ library
        if containsInRightSide  {
            imageView2.image = UIImage(named: "tree")
        } else {
            imageView1.image = UIImage(named: "phone")
        }
    }
    
}

extension UIImageView {
    func getCut(with bezier: UIBezierPath) -> UIImageView {

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezier.cgPath

        self.layer.mask = shapeLayer
        
        return self
    }
}
