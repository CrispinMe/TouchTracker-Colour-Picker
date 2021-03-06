//
//  DrawView.swift
//  TouchTracker
//
//  Created by Crispin Lloyd on 01/01/2020.
//  Copyright © 2020 Big Nerd Ranch. All rights reserved.
//

import UIKit

class DrawView: UIView, UIGestureRecognizerDelegate {
    
    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()
    var selectedLineIndex: Int? {
        didSet {
            if selectedLineIndex == nil {
                let menu = UIMenuController.shared
                menu.hideMenu(from: self)
            }
        }
    }
    
    var moveRecognizer: UIPanGestureRecognizer!
    
    @IBInspectable var finishedLineColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var currentLineColor: UIColor = UIColor.red {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    //Create colour array to be able to choose colours with which to draw lines
    let colours = [UIColor.green, UIColor.blue, UIColor.magenta, UIColor.red, UIColor.black]
    
    //Create stack view to hold colour selection buttons
    let colourButtonsStackView: UIStackView = UIStackView()
    
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
         
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.tap(_:)))
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.require(toFail: doubleTapRecognizer)
        addGestureRecognizer(tapRecognizer)
        
        //let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DrawView.longPress(_:)))
        //addGestureRecognizer(longPressRecognizer)
        
        //moveRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawView.moveLine(_:)))
        //moveRecognizer.delegate = self
        //moveRecognizer.cancelsTouchesInView = false
        //addGestureRecognizer(moveRecognizer)
        
        let upSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(DrawView.upSwipe(_:)))
        
        upSwipeRecognizer.numberOfTouchesRequired = 2
        upSwipeRecognizer.direction = .up
        addGestureRecognizer(upSwipeRecognizer)
        
        
        //Loop through colours array and populate the colourButtonsStackView
        for colour in colours {
            let colourButton = UIButton(frame: CGRect(x:0, y:0, width: 100, height: 100))
            colourButton.backgroundColor = colour
            colourButton.addTarget(self, action: #selector(colourButtonClick(_:)), for: .touchUpInside)
            
            //Add the button to the colourButtonsStackView
            colourButtonsStackView.addArrangedSubview(colourButton)
        }
        
        
        
        //Add label to the top of the stack view to advise the user to select a colour
        let headingLabel:UILabel = UILabel(frame: CGRect(x:0, y:0, width: 100, height: 100))
        headingLabel.text = "Please select a colour"
        
        colourButtonsStackView.insertArrangedSubview(headingLabel,  at: 0)
        
        //Set the axis and fill for the stack view
        colourButtonsStackView.axis = .vertical
        colourButtonsStackView.distribution = .fillEqually
        
        //Add the stack view to DrawView and set the layout
        colourButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(colourButtonsStackView)
        
        let margins = self.layoutMarginsGuide
        let topConstraint = colourButtonsStackView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 10)
        let leadingConstraint = colourButtonsStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor)
        let trailingConstraint = colourButtonsStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        
        topConstraint.isActive = true
        leadingConstraint.isActive = true
        //trailingConstraint.isActive = true
        
        //Hide colourButtonsStackView until activated by the user
        colourButtonsStackView.isHidden = true

        
        
        
        
        
        
        
    }
        
        
    override var canBecomeFirstResponder: Bool {
        return true
    }
    

    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func stroke(_ line: Line){
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = .round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    override func draw(_ rect: CGRect){
        for line in finishedLines {
            line.lineColor.setStroke()
            stroke(line)
            
        }
        
        currentLineColor.setStroke()
        for (_, line) in currentLines {
            stroke(line)
        }
        
        if let index = selectedLineIndex {
            UIColor.green.setStroke()
            let selectedLine = finishedLines[index]
            stroke(selectedLine)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        //Log statement to see the order of events
        print(#function)
        
        
        for touch in touches {
            let location = touch.location(in: self)
            
            let newLine = Line(begin: location, end: location)
            
            let key = NSValue(nonretainedObject: touch)
            currentLines[key] = newLine
        
        
        setNeedsDisplay()
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        //Log statement to see the order of events
        print(#function)
        
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.location(in: self)
            
        }
        
        setNeedsDisplay()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        //Log statement to see the order of events
        print(#function)
        
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            if var line = currentLines[key] {
                line.end = touch.location(in: self)
                
                //Set the line colour to the value for the currentLineColor property
                line.lineColor = self.currentLineColor
                
                
                print ("begin.y:", line.begin.y)
                print ("end.y:", line.end.y)
                
                finishedLines.append(line)
                currentLines.removeValue(forKey: key)
            }
        }
        
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Log statement to see the order of events
        print(#function)
        
        currentLines.removeAll()
        
        setNeedsDisplay()
    }
    
    @objc func doubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a double tap")
        
        selectedLineIndex = nil
        currentLines.removeAll()
        finishedLines.removeAll()
        setNeedsDisplay()
    }
    
    @objc func tap(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a tap")
        
        let point = gestureRecognizer.location(in: self)
        selectedLineIndex = indexOfLine(at: point)
        
        //Grab the menu controller
        let menu = UIMenuController.shared
        
        if selectedLineIndex != nil {
            
            //Make DrawView the target of menu item action messages
            becomeFirstResponder()
            
            //Create a new "Delete" UIMenuItem
            let deleteItem = UIMenuItem(title: "Delete", action: #selector(DrawView.deleteLine(_:)))
            menu.menuItems = [deleteItem]
            
            //Tell the menu where it should come from and show it
            let targetRect = CGRect(x: point.x, y: point.y, width: 2, height: 2)
            menu.showMenu(from: self, rect: targetRect)
            
        } else {
            
            //Hide the menu if no line is selected
            menu.hideMenu(from: self)
        }
        
        setNeedsDisplay()
    }
    
    @objc func longPress(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a long press")
        
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: self)
            selectedLineIndex = indexOfLine(at: point)
            
            if selectedLineIndex != nil {
                currentLines.removeAll()
                
            }
        } else if gestureRecognizer.state == .ended {
            selectedLineIndex = nil
        }
        
        setNeedsDisplay()
    }
    
   @objc func moveLine(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("Recognized a pan")
    
    //If a line is selected...
    if let index = selectedLineIndex {
        
        //When the pan recognizer changes its position...
        if gestureRecognizer.state == .changed {
            //How far has the pan moved?
            let translation = gestureRecognizer.translation(in: self)
            
            //Add the translation to the current beginning and end points of the line
            //Make sure there are no copy and paste typos!
            finishedLines[index].begin.x += translation.x
            finishedLines[index].begin.y += translation.y
            finishedLines[index].end.x += translation.x
            finishedLines[index].end.y += translation.y
            
            gestureRecognizer.setTranslation(CGPoint.zero, in: self)
            
            //Redraw the screen
            setNeedsDisplay()
            }
        
        } else {
        //If no line is selected, do not do anything
        return
        }
    }
    
    @objc func upSwipe(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a swipe")
        
        //Unhide the stack view containing the colour selection buttons
        colourButtonsStackView.isHidden = false
        
        
    }
    
    @objc func colourButtonClick(_ button: UIButton) {
        if let buttonColor = button.backgroundColor {
            self.currentLineColor = buttonColor
        }
        
        //Hide colourButtonsStackView after colour has been selected
        colourButtonsStackView.isHidden = true
        
    }
    
    func indexOfLine(at point: CGPoint)->Int? {
        //Find a line close to point
        for (index, line) in finishedLines.enumerated() {
            let begin = line.begin
            let end = line.end
                 
            //Check a few points on the line
            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05) {
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                //If the tapped point is within 20 points, let's return this line
                if hypot(x - point.x, y - point.y) < 20.0 {
                    return index
                }
            }
        }
        
        //If nothing is close enough to the tapped point, then we did not select a line
        return nil
    }
    
     @objc func deleteLine(_ sender: UIMenuController) {
        //Remove the selected line from the list of finished lines
        if let index = selectedLineIndex {
            finishedLines.remove(at: index)
            selectedLineIndex = nil
            
            //Redraw everything
            setNeedsDisplay()
        }
    }
    
}
