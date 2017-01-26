//
//  VolumeButton.swift
//  VolumeButton
//
//  Created by Alberto Pasca on 25/01/17.
//  Copyright © 2017 albertopasca.it. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

public protocol VolumeButtonDelegate
{
    func volumeChanged()
}

open class VolumeButton: UIView {

    fileprivate let kMinVolume = 0.00001
    fileprivate let kMaxVolume = 0.99999
    
    open var delegate: VolumeButtonDelegate?
    fileprivate let volume = MPVolumeView(frame: CGRect.zero)
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public func destroy() {
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
    }
    
    fileprivate func setup() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Unable to initialize AVAudioSession")
        }
        
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: [.new], context: nil)
        
        volume.isUserInteractionEnabled = false
        volume.alpha = 0.0001
        volume.showsRouteButton = false
        addSubview(volume)

        fixMinMaxVolume()
    }
    
    fileprivate func fixMinMaxVolume() {
        var val : Float = 0.0
        for view in volume.subviews {
            if let slider = view as? UISlider {
                if slider.value == 0.0 { slider.value = Float(kMinVolume) }
                if slider.value == 1.0 { slider.value = Float(kMaxVolume) }
                val = slider.value
            }
        }
        print(val)
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change, let value = change[.newKey] as? Float , keyPath == "outputVolume" else { return }
        
        if ( value == Float(kMinVolume) || value == Float(kMaxVolume) ) {
            return
        }

        self.delegate?.volumeChanged()
        fixMinMaxVolume()
    }
    
    deinit {
        destroy()
    }
    
}
