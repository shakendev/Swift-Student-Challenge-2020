//
// Copyright (c) 2015 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

public class SwiftSpinner: UIView {
    
    // MARK: - Singleton
    
    //
    // Access the singleton instance
    //
    public class var sharedInstance: SwiftSpinner {
        struct Singleton {
            static let instance = SwiftSpinner(frame: CGRect.zero)
        }
        return Singleton.instance
    }
    
    // MARK: - Init
    
    //
    // Custom init to build the spinner UI
    //
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        blurEffect = UIBlurEffect(style: blurEffectStyle)
        blurView = UIVisualEffectView(effect: blurEffect)
        addSubview(blurView)
        
        
        
        //vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
        vibrancyView = UIVisualEffectView(effect: blurEffect)
        addSubview(vibrancyView)
        
        let titleScale: CGFloat = 0.85
        titleLabel.frame.size = CGSize(width: frameSize.width * titleScale, height: frameSize.height * titleScale)
        titleLabel.font = defaultTitleFont
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontSizeToFitWidth = true
        
        vibrancyView.contentView.addSubview(titleLabel)
        blurView.contentView.addSubview(vibrancyView)
        
        outerCircleView.frame.size = frameSize
        outerCircle.path = UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: frameSize.width, height: frameSize.height)).cgPath
        outerCircle.lineWidth = 8.0
        outerCircle.strokeStart = 0.0
        outerCircle.strokeEnd = 0.45
        outerCircle.lineCap = CAShapeLayerLineCap.round
        outerCircle.fillColor = UIColor.clear.cgColor
        outerCircle.strokeColor = UIColor.white.cgColor
        outerCircleView.layer.addSublayer(outerCircle)
        
        outerCircle.strokeStart = 0.0
        outerCircle.strokeEnd = 1.0
        
        vibrancyView.contentView.addSubview(outerCircleView)
        
        innerCircleView.frame.size = frameSize
        
        let innerCirclePadding: CGFloat = 12
        innerCircle.path = UIBezierPath(ovalIn: CGRect(x: innerCirclePadding, y: innerCirclePadding, width: frameSize.width - 2*innerCirclePadding, height: frameSize.height - 2*innerCirclePadding)).cgPath
        innerCircle.lineWidth = 4.0
        innerCircle.strokeStart = 0.5
        innerCircle.strokeEnd = 0.9
        innerCircle.lineCap = CAShapeLayerLineCap.round
        innerCircle.fillColor = UIColor.clear.cgColor
        innerCircle.strokeColor = UIColor.gray.cgColor
        innerCircleView.layer.addSublayer(innerCircle)
        
        innerCircle.strokeStart = 0.0
        innerCircle.strokeEnd = 1.0
        
        vibrancyView.contentView.addSubview(innerCircleView)
        
        isUserInteractionEnabled = true
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self
    }
    
    // MARK: - Public interface
    
    public lazy var titleLabel = UILabel()
    public var subtitleLabel: UILabel?
    
    //
    // Show the spinner activity on screen, if visible only update the title
    //
    public class func show(title: String, animated: Bool = true) -> SwiftSpinner {
        
        let window = UIApplication.shared.windows.first!
        let spinner = SwiftSpinner.sharedInstance
        
        spinner.showWithDelayBlock = nil
        spinner.clearTapHandler()
        
        spinner.updateFrame()
        
        if spinner.superview == nil {
            //show the spinner
            spinner.alpha = 0.0
            window.addSubview(spinner)
            
            UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseOut, animations: {
                spinner.alpha = 0.5
                }, completion: nil)
            
            // Orientation change observer
//            NotificationCenter.default.addObserver(
//                spinner,
//                selector: #selector(SwiftSpinner.updateFrame),
//                name: NSNotification.Name.UIApplication.didChangeStatusBarOrientationNotification,
//                object: nil)
        }
        
        spinner.title = title
        spinner.animating = animated
        
        return spinner
    }
    
    //
    // Show the spinner activity on screen, after delay. If new call to show,
    // showWithDelay or hide is maked before execution this call is discarded
    //
    public class func showWithDelay(delay: Double, title: String, animated: Bool = true) -> SwiftSpinner {
        let spinner = SwiftSpinner.sharedInstance
        
//        spinner.showWithDelayBlock = {
//            SwiftSpinner.show(title: title, animated: animated)
//        }
        
        spinner.delay(seconds: delay) { [weak spinner] in
            if let spinner = spinner {
                spinner.showWithDelayBlock?()
            }
        }
        
        return spinner
    }
    
    //
    // Hide the spinner
    //
    public class func hide(completion: (() -> Void)? = nil) {
        
        let spinner = SwiftSpinner.sharedInstance
        
        NotificationCenter.default.removeObserver(spinner)
        
        DispatchQueue.main.async { 
            spinner.showWithDelayBlock = nil
            spinner.clearTapHandler()
            
            if spinner.superview == nil {
                return
            }
            
            UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseOut, animations: {
                spinner.alpha = 0.0
                }, completion: {_ in
                    spinner.alpha = 1.0
                    spinner.removeFromSuperview()
                    spinner.titleLabel.font = spinner.defaultTitleFont
                    spinner.titleLabel.text = nil
                    
                    completion?()
            })
            
            spinner.animating = false
        }
    }
    
    //
    // Set the default title font
    //
    public class func setTitleFont(font: UIFont?) {
        let spinner = SwiftSpinner.sharedInstance
        
        if let font = font {
            spinner.titleLabel.font = font
        } else {
            spinner.titleLabel.font = spinner.defaultTitleFont
        }
    }
    
    //
    // The spinner title
    //
    public var title: String = "" {
        didSet {
            
            let spinner = SwiftSpinner.sharedInstance
            
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
                spinner.titleLabel.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                spinner.titleLabel.alpha = 0.2
                }, completion: {_ in
                    spinner.titleLabel.text = self.title
                    UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.35, initialSpringVelocity: 0.0, options: [], animations: {
                        spinner.titleLabel.transform =  CGAffineTransform.identity
                        spinner.titleLabel.alpha = 1.0
                        }, completion: nil)
            })
        }
    }
    
    //
    // observe the view frame and update the subviews layout
    //
    public override var frame: CGRect {
        didSet {
            if frame == CGRect.zero {
                return
            }
            blurView.frame = bounds
            vibrancyView.frame = blurView.bounds
            titleLabel.center = vibrancyView.center
            outerCircleView.center = vibrancyView.center
            innerCircleView.center = vibrancyView.center
            if let subtitle = subtitleLabel {
                subtitle.bounds.size = subtitle.sizeThatFits(bounds.insetBy(dx: 20.0, dy: 0.0).size)
                subtitle.center = CGPoint(x: bounds.midX, y: bounds.maxY - subtitle.bounds.midY - subtitle.font.pointSize)
            }
        }
    }
    
    //
    // Start the spinning animation
    //
    
    public var animating: Bool = false {
        
        willSet (shouldAnimate) {
            if shouldAnimate && !animating {
                spinInner()
                spinOuter()
            }
        }
        
        didSet {
            // update UI
            if animating {
                self.outerCircle.strokeStart = 0.0
                self.outerCircle.strokeEnd = 0.45
                self.innerCircle.strokeStart = 0.5
                self.innerCircle.strokeEnd = 0.9
            } else {
                self.outerCircle.strokeStart = 0.0
                self.outerCircle.strokeEnd = 1.0
                self.innerCircle.strokeStart = 0.0
                self.innerCircle.strokeEnd = 1.0
            }
        }
    }
    
    //
    // Tap handler
    //
    public func addTapHandler(tap: @escaping (()->()), subtitle subtitleText: String? = nil) {
        clearTapHandler()
        
        //vibrancyView.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("didTapSpinner")))
        tapHandler = tap
        
        if subtitleText != nil {
            subtitleLabel = UILabel()
            if let subtitle = subtitleLabel {
                subtitle.text = subtitleText
                subtitle.font = UIFont(name: defaultTitleFont.familyName, size: defaultTitleFont.pointSize * 0.8)
                subtitle.textColor = UIColor.white
                subtitle.numberOfLines = 0
                subtitle.textAlignment = .center
                subtitle.lineBreakMode = .byWordWrapping
                subtitle.bounds.size = subtitle.sizeThatFits(bounds.insetBy(dx: 20.0, dy: 0.0).size)
                subtitle.center = CGPoint(x: bounds.midX, y: bounds.maxY - subtitle.bounds.midY - subtitle.font.pointSize)
                vibrancyView.contentView.addSubview(subtitle)
            }
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if tapHandler != nil {
            tapHandler?()
            tapHandler = nil
        }
    }
    

    public func clearTapHandler() {
        isUserInteractionEnabled = false
        subtitleLabel?.removeFromSuperview()
        tapHandler = nil
    }
    
    // MARK: - Private interface
    
    //
    // layout elements
    //
    
    private var blurEffectStyle: UIBlurEffect.Style = .dark
    private var blurEffect: UIBlurEffect!
    private var blurView: UIVisualEffectView!
    private var vibrancyView: UIVisualEffectView!
    
    var defaultTitleFont = UIFont(name: "HelveticaNeue", size: 22.0)!
    let frameSize = CGSize(width: 200.0, height: 200.0)
    
    private lazy var outerCircleView = UIView()
    private lazy var innerCircleView = UIView()
    
    private let outerCircle = CAShapeLayer()
    private let innerCircle = CAShapeLayer()
    
    private var showWithDelayBlock: (()->())?
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Not coder compliant")
    }
    
    private var currentOuterRotation: CGFloat = 0.0
    private var currentInnerRotation: CGFloat = 0.1
    
    private func spinOuter() {
        
        if superview == nil {
            return
        }
        
        let duration = Double(Float(arc4random()) /  Float(UInt32.max)) * 2.0 + 1.5
        let randomRotation = Double(Float(arc4random()) /  Float(UInt32.max)) * (.pi / 4) + (.pi / 4)
        
        //outer circle
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [], animations: {
            self.currentOuterRotation -= CGFloat(randomRotation)
            self.outerCircleView.transform = CGAffineTransform(rotationAngle: self.currentOuterRotation)
            }, completion: {_ in
                let waitDuration = Double(Float(arc4random()) /  Float(UInt32.max)) * 1.0 + 1.0
                self.delay(seconds: waitDuration, completion: {
                    if self.animating {
                        self.spinOuter()
                    }
                })
        })
    }
    
    private func spinInner() {
        if superview == nil {
            return
        }
        
        //inner circle
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: {
            self.currentInnerRotation += .pi / 4
            self.innerCircleView.transform = CGAffineTransform(rotationAngle: self.currentInnerRotation)
            }, completion: {_ in
                self.delay(seconds: 0.5, completion: {
                    if self.animating {
                        self.spinInner()
                    }
                })
        })
    }
    
    @objc public func updateFrame() {
        let window = UIApplication.shared.windows.first!
        SwiftSpinner.sharedInstance.frame = window.frame
    }
    
    // MARK: - Util methods
    
    func delay(seconds: Double, completion:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { 
            completion()
        }
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
    }
    
    // MARK: - Tap handler
    private var tapHandler: (()->())?
    func didTapSpinner() {
        tapHandler?()
    }
}
