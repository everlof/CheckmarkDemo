//
//  AnimationView.swift
//  CheckmarkDemo
//
//  Created by Guilherme Rambo on 07/11/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

class AnimationView: UIView {

    let animationLayer: CALayer

    init(archive: AnimationArchive) {
        animationLayer = archive.rootLayer
        super.init(frame: .zero)
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        stop()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationDuration(0)

        installAnimationLayerIfNeeded()
        layoutAnimationLayer()

        CATransaction.commit()
    }

    func stop() {
        animationLayer.timeOffset = 0
        animationLayer.speed = 0
    }

    func pause() {
        if animationLayer.speed > .ulpOfOne {
            let pausedTime = animationLayer.convertTime(CACurrentMediaTime(), from: nil)
            animationLayer.speed = 0.0
            animationLayer.timeOffset = pausedTime
        } else {
            let pausedTime = animationLayer.timeOffset
            animationLayer.speed = 1.0
            animationLayer.timeOffset = 0.0
            animationLayer.beginTime = 0.0
            let timeSincePause = animationLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            animationLayer.beginTime = timeSincePause
        }
    }

    func set(progress: CGFloat) {
        animationLayer.timeOffset = CFTimeInterval(progress) * animationLayer.duration
    }

    func play() {
        animationLayer.speed = 1.0
        animationLayer.beginTime = CACurrentMediaTime()
        animationLayer.timeOffset = 0.0
    }

    private func installAnimationLayerIfNeeded() {
        guard animationLayer.superlayer == nil else { return }

        animationLayer.isGeometryFlipped = false
        animationLayer.duration = findLatestEndTime()
        layer.addSublayer(animationLayer)
    }

    private func layoutAnimationLayer() {
        let layerWidth = animationLayer.bounds.width
        let layerHeight = animationLayer.bounds.height

        let aspectWidth  = bounds.width / layerWidth
        let aspectHeight = bounds.height / layerHeight

        let fitRatio = min(aspectWidth, aspectHeight)
        animationLayer.transform = transform(for: fitRatio, contentSize: animationLayer.bounds.size)
    }

    private func findLatestEndTime() -> CFTimeInterval {
        return findLatestEndTimeRecursive(layer: animationLayer)
    }

    private func findLatestEndTimeRecursive(layer: CALayer) -> CFTimeInterval {
        guard let sublayers = layer.sublayers else { return findLatestEndTimeIn(layer: layer) }
        return sublayers.map { findLatestEndTimeRecursive(layer: $0) }.max() ?? .leastNonzeroMagnitude
    }

    private func findLatestEndTimeIn(layer: CALayer) -> CFTimeInterval {
        guard let keys = layer.animationKeys() else { return .leastNonzeroMagnitude }
        return
            keys.map {
                layer.animation(forKey: $0)
            }
            .compactMap { $0 }
            .map { $0.beginTime + $0.duration }
            .max() ?? .leastNonzeroMagnitude
    }

    private func transform(for ratio: CGFloat, contentSize: CGSize) -> CATransform3D {
        let scale = CATransform3DMakeScale(ratio, ratio, 1)

        let tx = (bounds.width - (contentSize.width * ratio))/2.0
        let ty = (bounds.height - (contentSize.height * ratio))/2.0

        let translation = CATransform3DMakeTranslation(tx, ty, 0)

        return CATransform3DConcat(scale, translation)
    }

}
