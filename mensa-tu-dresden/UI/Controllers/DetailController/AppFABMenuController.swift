

import UIKit
import Material
import Motion

class AppFABMenuController: FABMenuController {
    let fabMenuSize = CGSize(width: 56, height: 56)
    let bottomInset: CGFloat = 24
    let rightInset: CGFloat = 24
    
    var fabButton: FABButton!
    var rateFABMenuItem: FABMenuItem!
    
    var meal: Meal!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func prepare() {
        super.prepare()
        view.backgroundColor = .white
        
        prepareFABButton()
        prepareMenuItems()
        prepareFABMenu()
    }

    func prepareFABButton() {
        fabButton = FABButton(image: Icon.cm.moreVertical, tintColor: .white)
        fabButton.backgroundColor = Colors.backgroundColor
        fabButton.pulseColor = .white
    }
    
    func prepareMenuItems() {
        rateFABMenuItem = FABMenuItem()
        rateFABMenuItem.titleLabel.attributedText = "Bewerte dieses Essen".attributed(withBackgroundColor: .white)
        rateFABMenuItem.fabButton.image = Icon.cm.pen
        rateFABMenuItem.fabButton.tintColor = .white
        rateFABMenuItem.fabButton.pulseColor = .white
        rateFABMenuItem.fabButton.backgroundColor = Colors.colorFor(string: meal.mensa)
        rateFABMenuItem.fabButton.addTarget(self, action: #selector(handleRateButtonTouched), for: .touchUpInside)
    }
    
    @objc func handleRateButtonTouched() {
        let vc = RatingController.fromStoryboard()
        vc.meal = meal
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func prepareFABMenu() {
        fabMenu.fabButton = fabButton
        fabMenu.fabMenuItems = [rateFABMenuItem]
        
        view.layout(fabMenu)
            .size(fabMenuSize)
            .bottom(bottomInset)
            .right(rightInset)
    }

    @objc open func fabMenuWillOpen(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(.rotate(45))
    }
    
    @objc open func fabMenuDidOpen(fabMenu: FABMenu) {
    }
    
    @objc open func fabMenuWillClose(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(.rotate(0))
    }
    
    @objc open func fabMenuDidClose(fabMenu: FABMenu) {
    }
    
    @objc open func fabMenu(fabMenu: FABMenu, tappedAt point: CGPoint, isOutside: Bool) {
        guard isOutside else {
            return
        }
    }
}

