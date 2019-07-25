//
//  SendMeMailController.swift
//  PBike
//
//  Created by 陳 冠禎 on 2016/12/29.
//  Copyright © 2016年 陳 冠禎. All rights reserved.
//

import MessageUI

extension MapViewController: MFMailComposeViewControllerDelegate {

    @IBAction func errorReportBtnPressed(_ sender: AnyObject) {
        presentErrorMailReport()
    }

    @IBAction func ratingBtnPressed(_ sender: AnyObject) {
        let appID = "1192891004"
        let head = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id="
        let foot = "&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
        let url = head + appID + foot

        guard let checkURL = URL(string: url) else { return }
        guard UIApplication.shared.canOpenURL(checkURL) else { return }
        UIApplication.shared.openURL(checkURL)
    }

    @IBAction func shareBtnPressed(_ sender: AnyObject) {
        guard let name = NSURL(string: applink) else { return }
        let objectsToShare = [name]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        if UIDevice.current.userInterfaceIdiom == .pad {

            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            activityVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }

        self.present(activityVC, animated: true, completion: nil)
    }

    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        //Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property

        mailComposerVC.setToRecipients(["pbikemapvision@gmail.com"])
        mailComposerVC.setSubject(self.mailtitle)
        mailComposerVC.setMessageBody("我們非常感謝您使用此App，歡迎寫下您希望的功能/錯誤回報或是合作洽談，謝謝", isHTML: false)

        return mailComposerVC
    }

    func showSendMailErrorAlert() {
        let alertController = UIAlertController(title: "無法傳送Email", message: "目前無法傳送郵件，請檢查E-mail設定並在重試", preferredStyle: .alert)
        //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
        let DestructiveAction = UIAlertAction(title: "OK", style: .destructive) {
            (_ : UIAlertAction) -> Void in
            print("Destructive")
        }

        alertController.addAction(DestructiveAction)

    }

    // MARK: MFMailComposeViewControllerDelegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    fileprivate func presentErrorMailReport() {

        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "hasSharedApp")

        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeViewController, animated: true, completion: nil)

        } else { showSendMailErrorAlert() }

    }

}
