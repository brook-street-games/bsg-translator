//
//  TranslationViewController.swift
//
//  Created by JechtSh0t on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import UIKit
import BSGTranslator

///
/// Canvas for testing the functionality of BSGTranslator.
///
final class TranslationViewController: UIViewController {
    
    // MARK: - Properties -
    
    private var language: Language = .english
    private lazy var translator = Translator(apiKey: "API_KEY", inputLanguage: "en", inputType: .stringsFile(fileName: "Test"), delegate: self)
    
    // MARK: - UI -
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .lightGray
        textView.isEditable = false
        return textView
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        
        let titles = Language.allCases.map { $0.alpha2 }
        let segmentedControl = UISegmentedControl(items: titles)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.selectedSegmentTintColor = UIColor.lightGray
        segmentedControl.backgroundColor = .black
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private lazy var slider: UISlider = {
       
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 5
        slider.minimumTrackTintColor = .black
        slider.maximumTrackTintColor = .lightGray
        slider.addTarget(self, action: #selector(sliderMoved(_:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var translationIdLabel: UILabel = {
       
        let label = UILabel()
        label.text = "ID: 0"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Translate", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Setup -
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.darkGray
        setup()
    }
    
    private func setup() {
        
        let stackView = UIStackView(arrangedSubviews: [textView, segmentedControl, slider, translationIdLabel, button])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        textView.addConstraint(NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120))
        segmentedControl.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
        slider.addConstraint(NSLayoutConstraint(item: slider, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30))
        translationIdLabel.addConstraint(NSLayoutConstraint(item: translationIdLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25))
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
        view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.8, constant: 0))
    }
}

// MARK: - Actions -

extension TranslationViewController {
    
    @objc private func sliderMoved(_ sender: UISlider) {
        translationIdLabel.text = "ID: \(Int(slider.value))"
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        
        guard let language = Language(rawValue: segmentedControl.selectedSegmentIndex) else { return }
        translator.updateTranslations(targetLanguage: language.alpha2, translationId: Int(slider.value))
    }
}

// MARK: - Translation -

extension TranslationViewController: TranslatorDelegate {
    
    func translator(_ translator: Translator, didReceiveTranslationSet translationSet: TranslationSet) {
        
        print("\n\(translationSet.description)")
        textView.text = translationSet.description
    }
    
    func translator(_ translator: Translator, didEncounterLogEvent logEvent: String) {
        print("LOG EVENT: \(logEvent)")
    }
    
    func translator(_ translator: Translator, didEncounterError error: TranslationError) {
        print("ERROR: \(error.localizedDescription)")
    }
}

// MARK: - Languages -

extension TranslationViewController {
    
    enum Language: Int, CaseIterable {
        case english, spanish, italian
        
        var alpha2: String {
            switch self {
            case .english: return "en"
            case .spanish: return "es"
            case .italian: return "it"
            }
        }
    }
}
