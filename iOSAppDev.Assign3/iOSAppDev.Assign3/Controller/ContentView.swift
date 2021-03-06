//
//  ContentView.swift
//  iOSAppDev.Assign3
//
//  Created by Nicholas on 21/5/22.
//

import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @ObservedObject var TinderVM: TinderViewModel
    @State var restaurants = Restaurant.restaurants
    
    var body: some View {
        //load in cards from the Restaurant folder into a ZStack
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(restaurants.enumerated()), id: \.offset) { index, user in
                    CardView(
                        TinderVM: TinderViewModel(), proxy: proxy,
                        restaurant: user,
                        index: index
                    ) { (index) in
                        restaurants.remove(at: index)
                        if index > 0 {
                            restaurants[index - 1].isBehind = false
                        }
                    }
                }
                //Create the join session and create session buttons
                Button("Join", action: {
                    TinderVM.join()
                }).position(x: proxy.frame(in: .local).midX + 70)
                Button("Create", action: {
                    TinderVM.advertise()
                }).position(x: proxy.frame(in: .local).midX - 70)
            }
        }
    }
}

class TinderViewModel: NSObject, ObservableObject {
    @Published private var Tinder = MCCreateViewController()
    
    let ServiceType = "food-tinder"
    var peerID: MCPeerID
    var session: MCSession
    var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser?
    var myResponse:String? = "undecided"
    var theirResponse:String? = "undecided"
    var isMatch:Bool = false
    
    
    //initialise base variables for MultipeerConnectivity
    override init() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        session.delegate = self
    }
    
    //Creates a session for other devices to join
    func advertise() {
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: ServiceType)
        nearbyServiceAdvertiser?.delegate = self
        nearbyServiceAdvertiser?.startAdvertisingPeer()
    }
    
    //Find and join an open session
    func join() {
        let browser = MCBrowserViewController(serviceType: ServiceType, session: session)
        browser.delegate = self
        UIApplication.shared.windows.first?.rootViewController?.present(browser , animated: true)
    }
    
    //packages the message to be sent to the connected peer. The message is that the user "DidSwipeNo"
    func didSwipeNo(at msg: String) {
        print("I am sending no")
        if let msgData = msg.data(using: .utf8) {
            try? session.send(msgData, toPeers: session.connectedPeers, with: .reliable)
        }
    }
    
    //packages the message to be sent to the connected peer. The message is that the user "DidSwipeYes"
    func didSwipeYes(at msg: String) {
        print("I am sending yes")
        if let msgData = msg.data(using: .utf8) {
            try? session.send(msgData, toPeers: session.connectedPeers, with: .reliable)
        }
    }
    
    //function gets both the client's response and the connected peer's response and compares the two
    func checkIfMatch (msg:String, myResponse:String) -> Bool {
        if myResponse == "Yes" && msg == "didPressYes"{
            print("We have a Match!")
            resetResponses()
            return true
        } else if myResponse == "No" && msg == "didPressYes"{
            print("no match, go next")
            resetResponses()
            return false
        } else if myResponse == "No" && msg == "didPressNo"{
            print("no match, go next")
            resetResponses()
            return false
        } else if myResponse == "Yes" && msg == "didPressNo" {
            print("no match, go next")
            resetResponses()
            return false
        } else {
            print("waiting on peer to answer")
            return false
        }
    }
    
    //after both devices have made a decision reset both responses
    func resetResponses () {
        myResponse = "undecided"
        theirResponse = "undecided"
    }
}


extension TinderViewModel: MCSessionDelegate {
    //when connecting to a device, keep track of all states of connectivity
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connecting:
            print("\(peerID) state: connecting")
        case .connected:
            print("\(peerID) state: connected")
        case .notConnected:
            print("\(peerID) state: not connected")
        @unknown default:
            print("\(peerID) state: unknown")
        }
    }
    
    //calls whenever the device receives a set of data during the session
    //Note: we were having issues trying to get the data to be received. Even though the same implementation was working when we used UIKit
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceive Data from \(peerID)")
        if let msg = String(data: data, encoding: .utf8){
            print("received: \(msg)")
        
            DispatchQueue.main.async {
                //TODO: this will call checkIfMatch 
            }
        }
    }
    
    //stubbed protocol function
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    //stubbed protocol function
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    //stubbed protocol function
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

extension TinderViewModel: MCNearbyServiceAdvertiserDelegate {
    //protocol function for when the user has created a session
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension TinderViewModel: MCBrowserViewControllerDelegate {
    // protocol function that closes the join session window when clicking Done
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    // protocol function that closes the join session window when cancelling
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(TinderVM: TinderViewModel())
    }
}
