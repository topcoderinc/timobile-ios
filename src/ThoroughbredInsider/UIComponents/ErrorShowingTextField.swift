//
//  ErrorShowingTextField.swift
//  Thoroughbred
//
//  Created by TCCODER on 30/10/17.
//  Copyright © 2017 topcoder. All rights reserved.
//

import UIKit

/**
 * Textfield capable of showing errors
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable
open class ErrorShowingTextField: UITextField {

    /// color for error highlight
    @IBInspectable open var errorColor: UIColor = UIColor.red
    
    /**
     textfield types enum
     
     - Text:   simple text
     - Picker: value picker
     - Date:   date picker
     */
    public enum TextfieldType: Int {
        case text, picker, date
    }
    
    /// textfield type
    @IBInspectable open var textfieldType: Int = 0 {
        didSet {
            type = TextfieldType(rawValue: textfieldType) ?? .text
        }
    }
    open var type: TextfieldType = .text {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// toggles error highlight
    open var showError = false {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    /// the data for picker type
    open var pickerData: [PickerRowData] = []
    
    /// the configurable date picker mode
    open var datePickerMode: UIDatePickerMode = .dateAndTime {
        didSet {
            datePicker?.datePickerMode = datePickerMode
        }
    }
    
    /// the configurable date picker max date
    open var maxDate: Date? {
        didSet {
            datePicker?.maximumDate = maxDate
        }
    }

    /// the configurable date picker min date
    open var minDate: Date? {
        didSet {
            datePicker?.minimumDate = minDate
        }
    }

    /// the configurable date formatter
    open var defaultDateFormatter: DateFormatter {
        return DateFormatter()
    }
    
    /// custom date formatter
    open var customDateFormatter: DateFormatter?
    
    /// underlying picker
    fileprivate var picker: UIPickerView?
    
    /// underlying picker
    fileprivate var datePicker: UIDatePicker?
    
    /// current value
    open var value: AnyObject {
        get {
            switch type {
            case .text:
                return self.textValue as AnyObject
            case .picker:
                if let v = lastValue {
                    return v
                }
                let selection = pickerData[picker!.selectedRow(inComponent: 0)]
                return selection.payload ?? selection.text as AnyObject
            case .date:
                return lastValue as? Date as AnyObject? ?? datePicker!.date as AnyObject
            }
        }
        set {
            switch type {
            case .text:
                self.text = newValue as? String
            case .picker:
                var row = 0
                for data in pickerData {
                    if data.payload?.isEqual(newValue) == true || data.text == newValue as? String {
                        picker?.selectRow(row, inComponent: 0, animated: false)
                        lastValue = newValue
                        break
                    }
                    row += 1
                }
            case .date:
                datePicker?.date = newValue as! Date
                lastValue = newValue
            }
        }
    }
    
    /// last value for pickers
    open var lastValue: AnyObject?
    
    /**
     awake from nib
     */
    open override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(ErrorShowingTextField.textChanged(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: self)
    }
    
    /**
     layout
     */
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // configure input
        switch type {
        case .text:
            self.inputView = nil
        case .picker:
            let picker = UIPickerView()
            picker.dataSource = self
            picker.delegate = self
            self.inputView = picker
            self.picker = picker
        case .date:
            let picker = UIDatePicker()
            picker.addTarget(self, action: #selector(ErrorShowingTextField.dateChanged(_:)), for: .valueChanged)
            picker.datePickerMode = datePickerMode
            picker.minimumDate = minDate
            picker.maximumDate = maxDate
            self.inputView = picker
            self.datePicker = picker
        }
    }

    /**
     text change notification
     
     - parameter notif: notification data
     */
    @objc open func textChanged(_ notif: Notification) {
        self.showError = false
    }
    
    /**
     cleanup
     */
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // get focus
    open override func becomeFirstResponder() -> Bool {
        let res = super.becomeFirstResponder()
        if let lastValue = lastValue {
            switch type {
            case .text:
                break
            case .picker:
                value = lastValue
            case .date:
                value = lastValue
            }
        }
        return res
    }

    // lose focus
    open override func resignFirstResponder() -> Bool {
        if textValue.isEmpty {
            switch type {
            case .text:
                break
            case .picker:
                self.text = picker!.selectedRow(inComponent: 0) < pickerData.count ? pickerData[picker!.selectedRow(inComponent: 0)].text : self.text
            case .date:
                self.text = getDateFormatter().string(from: datePicker!.date)
            }
        }
        return super.resignFirstResponder()
    }
    
    /**
     date change handler
     
     - parameter picker: date picker
     */
    @objc func dateChanged(_ picker: UIDatePicker) {
        self.text = getDateFormatter().string(from: picker.date)
        showError = false
        lastValue = picker.date as AnyObject?
        self.sendActions(for: UIControlEvents.editingChanged)
    }
    
    /**
     Check if the field contains correct date
     
     - returns: true - if correct date was entered, false - else
     */
    open func isCorrectDate() -> Bool {
        if (self.text ?? "").isEmpty {
            return false
        }
        if let date = value as? Date {
            return (self.text ?? "") == getDateFormatter().string(from: date)
        }
        return false
    }
    
    /**
     Check if the field contains correct number
     
     - returns: true - if correct number was entered, false - else
     */
    open func isCorrectNumber() -> Bool {
        if let text = self.text {
            return pickerData.map{$0.text}.contains(text)
        }
        return false
    }
    
    /**
     Clean up field
     */
    open func cleanUp() {
        self.text = ""
        lastValue = nil
    }
    
    
    /**
     Get effective date formatter
     
     - returns: the formatter
     */
    open func getDateFormatter() -> DateFormatter {
        if let formatter = customDateFormatter {
            return formatter
        }
        return defaultDateFormatter
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension ErrorShowingTextField: UIPickerViewDataSource, UIPickerViewDelegate {

    // number of components
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // number of rows
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // attributed title
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int,
        forComponent component: Int) -> NSAttributedString? {
            let text = pickerData[row].text
            let selected = pickerView.selectedRow(inComponent: component) == row
            let attributedTitle = NSAttributedString(string: text,
                                                     attributes: [NSAttributedStringKey.font: selected ? UIFont.boldSystemFont(ofSize: 15) : UIFont.systemFont(ofSize: 15) ])
            return attributedTitle
    }
    
    // Selection handler
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < pickerData.count else { return }
        self.text = pickerData[row].text
        lastValue = pickerData[row].payload ?? pickerData[row].text as AnyObject?
        showError = false
        self.sendActions(for: UIControlEvents.editingChanged)
    }
}

/**
 *  represents a row data for picker
 */
public struct PickerRowData {
    /// text
    public var text: String
    /// corresponding data
    public var payload: AnyObject?
    
    /**
     initializes row
     
     - parameter text:    text
     - parameter payload: optional payload
     */
    public init(text: String, payload: AnyObject? = nil) {
        self.text = text
        self.payload = payload
    }
}

