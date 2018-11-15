// MIT License
//
// Copyright (c) 2018 David Everlöf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import UIKit

class ViewController: UIViewController {

    private let checkmarkView: AnimationView

    private let observationStackView = UIStackView()

    private let speedSlider = UISlider()

    private let playButton = UIButton()

    private let pauseButton = UIButton()

    private let stopButton = UIButton()

    private var observations = [NSKeyValueObservation]()

    enum Observings: Int {
        case timeOffset
        case beginTime
        case duration
        case repeatDuration
        case repeatCount
        case speed
    }

    init() {
        let archive = try! AnimationArchive(assetNamed: "Checkmark")
        checkmarkView = AnimationView(archive: archive)
        observationStackView.axis = .vertical
        super.init(nibName: nil, bundle: nil)

        add(key: "timeOffset", to: observationStackView)
        add(key: "beginTime", to: observationStackView)
        add(key: "duration", to: observationStackView)
        add(key: "repeatDuration", to: observationStackView)
        add(key: "repeatCount", to: observationStackView)
        add(key: "speed", to: observationStackView)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func add(key: String, to stackView: UIStackView) {
        let keyLabel = UILabel()
        let valueLabel = UILabel()
        keyLabel.text = key

        let localStackView = UIStackView()
        localStackView.axis = .horizontal

        localStackView.addArrangedSubview(keyLabel)
        localStackView.addArrangedSubview(valueLabel)

        stackView.addArrangedSubview(localStackView)
    }

    override func viewDidLoad() {
        observations.append(checkmarkView.animationLayer.observe(\CALayer.timeOffset, options: [.initial, .new]) { layer, change in
            (self.observationStackView.arrangedSubviews[0].subviews[1] as! UILabel).text = change.newValue.map { "\($0)" }
        })

        observations.append(checkmarkView.animationLayer.observe(\CALayer.beginTime, options: [.initial, .new]) { layer, change in
            (self.observationStackView.arrangedSubviews[1].subviews[1] as! UILabel).text = change.newValue.map { "\($0)" }
        })

        observations.append(checkmarkView.animationLayer.observe(\CALayer.duration, options: [.initial, .new]) { layer, change in
            (self.observationStackView.arrangedSubviews[2].subviews[1] as! UILabel).text = change.newValue.map { "\($0)" }
        })

        observations.append(checkmarkView.animationLayer.observe(\CALayer.repeatDuration, options: [.initial, .new]) { layer, change in
            (self.observationStackView.arrangedSubviews[3].subviews[1] as! UILabel).text = change.newValue.map { "\($0)" }
        })

        observations.append(checkmarkView.animationLayer.observe(\CALayer.repeatCount, options: [.initial, .new]) { layer, change in
            (self.observationStackView.arrangedSubviews[4].subviews[1] as! UILabel).text = change.newValue.map { "\($0)" }
        })

        observations.append(checkmarkView.animationLayer.observe(\CALayer.speed, options: [.initial, .new]) { layer, change in
            (self.observationStackView.arrangedSubviews[5].subviews[1] as! UILabel).text = change.newValue.map { "\($0)" }
        })

        view.backgroundColor = .white

        playButton.setTitle("Play", for: .normal)
        playButton.setTitleColor(UIColor.blue, for: .normal)

        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.setTitleColor(UIColor.blue, for: .normal)

        stopButton.setTitle("Stop", for: .normal)
        stopButton.setTitleColor(UIColor.blue, for: .normal)

        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pause), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stop), for: .touchUpInside)

        observationStackView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        speedSlider.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(observationStackView)
        view.addSubview(checkmarkView)
        view.addSubview(speedSlider)
        view.addSubview(playButton)
        view.addSubview(pauseButton)
        view.addSubview(stopButton)

        observationStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        observationStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        observationStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true

        checkmarkView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        checkmarkView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        checkmarkView.topAnchor.constraint(equalTo: observationStackView.bottomAnchor, constant: 30).isActive = true
        checkmarkView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playButton.topAnchor.constraint(equalTo: checkmarkView.bottomAnchor, constant: 20).isActive = true

        pauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pauseButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 14).isActive = true

        stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stopButton.topAnchor.constraint(equalTo: pauseButton.bottomAnchor, constant: 14).isActive = true

        speedSlider.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 20).isActive = true
        speedSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        speedSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true

        speedSlider.addTarget(self, action: #selector(didChangeSpeed(slider:)), for: .valueChanged)

        checkmarkView.play()
    }

    @objc func play() {
        checkmarkView.play()
    }

    @objc func pause() {
        checkmarkView.pause()
    }

    @objc func stop() {
        checkmarkView.stop()
    }

    @objc func didChangeSpeed(slider: UISlider) {
        checkmarkView.set(progress: CGFloat(slider.value))
    }

}
