//
//  InAppPurchaseManager.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 16.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import StoreKit
import Material

class DonationController: UIViewController, SKProductsRequestDelegate {
    
    var request: SKProductsRequest!
    var supporterProduct: SKProduct!
    
    @IBOutlet weak var button: IconButton!
    @IBOutlet weak var closeButton: IconButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var restoreButton: UIButton!
    
    static let hasntDonatedText = "Diese App ist kostenlos und soll es auch bleiben. Damit es auch in Zukunft möglich ist, diese App kostenlos anzubieten, brauchen wir deine Hilfe. Mit einem Klick auf das Herz wirst du Unterstützer und spendierst uns einen Kaffee ☕ Danke! 😎"
    
    static let hasDonatedText = "Vielen Dank für deine Spende! 😇"
    
    static func fromStoryboard() -> DonationController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let donationController = storyBoard.instantiateViewController(withIdentifier: "DonationController") as! DonationController
        return donationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        
        prepareUI()
        adjustToDonationStatus()
        
        if Donation.userHasDonated {
            showUI()
        } else {
            indicator.startAnimating()
            request = SKProductsRequest(productIdentifiers: Set(["Supporter"]))
            request.delegate = self
            request.start()
        }
        
    }
    
    func prepareUI() {
        button.setImage(UIImage(named: "heart"), for: .normal)
        button.addTarget(self, action: #selector(purchase), for: .touchUpInside)
        
        closeButton.setImage(Icon.cm.close, for: .normal)
        closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        closeButton.tintColor = Colors.backgroundColor
        
        label.numberOfLines = 0
        label.font = RobotoFont.regular(with: 15)
        label.textColor = Colors.backgroundColor
        
        backgroundView.layer.cornerRadius = 10.0
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        view.layout(blurredEffectView).top().bottom().left().right()
        blurredEffectView.isUserInteractionEnabled = false
        blurredEffectView.layer.zPosition = -1
    }
    
    func adjustToDonationStatus() {
        button.tintColor = Donation.userHasDonated ? Colors.redColor : Color.grey.lighten2
        label.text = Donation.userHasDonated ? DonationController.hasDonatedText : DonationController.hasntDonatedText
    }
    
    @IBAction func restore(_ sender: Any) {
        SKPaymentQueue.default().restoreCompletedTransactions()
        showLoadingIndicator()
    }
    
    @objc func purchase() {
        guard let supporterProduct = self.supporterProduct else {return}
        let payment = SKPayment(product: supporterProduct)
        SKPaymentQueue.default().add(payment)
        showLoadingIndicator()
    }
    
    @objc func dismissModal() {
        dismiss(animated: true)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let first = response.products.first, first.productIdentifier == "Supporter" {
            self.supporterProduct = first
        }
        showUI()
    }
    
    func showLoadingIndicator() {
        indicator.isHidden = false
        button.isHidden = true
        label.isHidden = true
        restoreButton.isHidden = true
    }
    
    func showUI() {
        indicator.isHidden = true
        button.isHidden = false
        label.isHidden = false
        restoreButton.isHidden = false
        restoreButton.isHidden = Donation.userHasDonated
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        NSLog("%@", error as NSError)
        self.request = nil
    }
    
}

extension DonationController: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case _ where [.purchased, .restored].contains(transaction.transactionState):
                Donation.userHasDonated = true
                adjustToDonationStatus()
                queue.finishTransaction(transaction)
            case .failed:
                print("Failed")
                queue.finishTransaction(transaction)
            default:
                break
            }
        }
        showUI()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        Donation.userHasDonated = true
        adjustToDonationStatus()
        showUI()
    }
    
}
