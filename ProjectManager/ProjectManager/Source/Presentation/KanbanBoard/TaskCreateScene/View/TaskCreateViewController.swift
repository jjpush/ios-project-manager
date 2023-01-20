//
//  TaskCreateViewController.swift
//  ProjectManager
//
//  Created by ayaan, jpush on 2023/01/18.
//

import UIKit

import RxCocoa
import RxSwift

final class TaskCreateViewController: UIViewController {
    private let viewModel: TaskCreateViewModel
    private let disposeBag = DisposeBag()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOffset = CGSize(width: 0, height: 4)
        textField.layer.shadowOpacity = 0.3
        textField.layer.shadowRadius = 5
        textField.layer.masksToBounds = false
        
        textField.font = .boldSystemFont(ofSize: 24)
        textField.backgroundColor = .systemBackground
        
        return textField
    }()
    private let datePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        return datePicker
    }()
    private let contentTextView: UITextView = {
        let textView = UITextView()
        
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 0, height: 2)
        textView.layer.shadowOpacity = 0.5
        textView.layer.shadowRadius = 5
        textView.layer.masksToBounds = false
        
        textView.font = .systemFont(ofSize: 18)
        textView.backgroundColor = .systemBackground
        
        return textView
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        
        return stackView
    }()
    private let cancelBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(systemItem: .cancel)
        
        return barButton
    }()
    private let doneBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(systemItem: .done)
        
        return barButton
    }()
    
    init(viewModel: TaskCreateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarButton()
        setUI()
        bind()
    }
}

private extension TaskCreateViewController {
    func setUI() {
        let spacing: CGFloat = 8
        let safeArea = view.safeAreaLayoutGuide
        
        [titleTextField, datePickerView, contentTextView].forEach { view in
            stackView.addArrangedSubview(view)
        }
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        
        titleTextField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        contentTextView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: spacing),
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: spacing),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -spacing),
            stackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -spacing),
        ])
    }
    
    func setNavigationBarButton() {
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = doneBarButton
    }
    
    func bind() {
        let input = TaskCreateViewModel.Input(titleDidEditEvent: titleTextField.rx.text.orEmpty.asObservable(),
                                              contentDidEditEvent: contentTextView.rx.text.orEmpty.asObservable(),
                                              datePickerDidEditEvent: datePickerView.rx.date.asObservable(),
                                              doneButtonTapEvent: doneBarButton.rx.tap.asObservable(),
                                              cancelButtonTapEvent: cancelBarButton.rx.tap.asObservable())
        
        let output = viewModel.transform(from: input)
        
        output.isFill
            .subscribe(onNext: { [weak self] isFill in
                self?.doneBarButton.isEnabled = isFill
            })
            .disposed(by: disposeBag)
        
        output.isSuccess
            .subscribe(onNext: { [weak self] isSuccess in
                if !isSuccess {
                    self?.showAlert()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func showAlert() {
        // 실패 알럿 alert
    }
}
