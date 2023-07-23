import UIKit
import RxSwift
import RxCocoa

class KMAgreementViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private let viewModel: KMAgreementViewModel
    
    var confirmCompletion: (() -> ())? = nil
    
    private let containerView = UIView().then {
        $0.backgroundColor = .color_background_01()
    }
    private let allAgreeButton = Base50CheckBox(frame: .zero, text: "shihnan_agreement_all_agree".localized).then {
        $0.checkButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        $0.checkButton.titleLabel?.font = .defaultBoldFont(size: 16)
        $0.showingButton.isHidden = true
    }
    private let cancelButton = UIButton().then {
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(.color_gray_50(), for: .normal)
        $0.titleLabel?.font = .defaultFont(size: 14)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    private let separatorLine = UIView().then {
        $0.backgroundColor = .color_gray_06()
    }
    private let verticalStackView = UIStackView().then {
        $0.axis = .vertical
    }
    
    private let bottomButton = SolidButton().then {
        $0.setBackgroundColor(color: .color_gray80_korbitBlue(), forState: .normal)
        $0.setBackgroundColor(color: .color_gray_50(), forState: .disabled)
        $0.setTitleColor(.color_gray_00(), for: .normal)
        $0.setTitleColor(.color_gray_10(), for: .disabled)
        $0.isEnabled = false
        $0.setTitle("shihnan_agreement_bottom_button_title".localized)
    }

    private let dimAreaView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    var mainButtons: [Int: NoBorderCheckButton] = [:]
    var subButtons: [Int: NoBorderCheckButton] = [:]
    
    init(viewModel: KMAgreementViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAgreementView()
        setupGesture()
        setupEvent()
        setupBinding()
    }
    
    private func setupView() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.view.addSubviews(dimAreaView, containerView)
        containerView.addSubviews(allAgreeButton, cancelButton, separatorLine, verticalStackView, bottomButton)
        
        dimAreaView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(containerView.snp.top)
        }
        containerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        allAgreeButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(60)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(cancelButton.snp.leading).offset(-4)
        }
        cancelButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(allAgreeButton.snp.centerY)
        }
        separatorLine.snp.makeConstraints {
            $0.top.equalTo(allAgreeButton.snp.bottom)
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        verticalStackView.snp.makeConstraints {
            $0.top.equalTo(separatorLine.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        bottomButton.snp.makeConstraints {
            $0.top.equalTo(verticalStackView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(54)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-12)
        }
    }
    
    private func setupAgreementView() {
        viewModel.agreementSections.enumerated().forEach { (index, item) in
            
            // 메인버튼 추가
            let mainCheckButton = makeMainCheckButton(index: index, title: item.mainAgreement.value.title)
            mainButtons[index] = mainCheckButton
            verticalStackView.addArrangedSubview(mainCheckButton)
            
            // 서브 버튼 추가
            if !item.subAgreements.isEmpty {
                let subAgreementsView = SubAgreementContainerView()
                
                item.subAgreements.enumerated()
                    .forEach { (subIndex, subItem) in
                        let newIndex = index * 10 + subIndex
                        let subCheckButton = makeSubCheckButton(index: newIndex, title: subItem.value.title)
                        subAgreementsView.addArrangedSubview(subCheckButton)
                        subButtons[newIndex] = subCheckButton
                }
                
                verticalStackView.addArrangedSubview(subAgreementsView)
            }
        }
    }
    
    private func setupGesture() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCancel))
        dimAreaView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func setupEvent() {
        allAgreeButton.checkButton.addTarget(self, action: #selector(didTapAllAgreement), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        bottomButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    private func makeMainCheckButton(index: Int, title: String) -> NoBorderCheckButton {
        let button = NoBorderCheckButton(style: .mainAgreement, text: title)
        button.checkButton.tag = index
        button.checkButton.addTarget(self, action: #selector(toggleMainAgreement(sender:)), for: .touchUpInside)
        button.showingButton.tag = index
        button.showingButton.addTarget(self, action: #selector(showMainAgreementDetail(sender:)), for: .touchUpInside)
        
        return button
    }
    
    private func makeSubCheckButton(index: Int, title: String) -> NoBorderCheckButton {
        let button = NoBorderCheckButton(style: .subAgreement, text: title)
        button.checkButton.tag = index
        button.checkButton.addTarget(self, action: #selector(toggleSubAgreement(sender:)), for: .touchUpInside)
        button.showingButton.tag = index
        button.showingButton.addTarget(self, action: #selector(showSubAgreementDetail(sender:)), for: .touchUpInside)
        
        return button
    }
    
    private func setupBinding() {
        viewModel.isAllAgreement
            .asDriver()
            .drive(onNext: { [weak self] isAgreed in
                self?.allAgreeButton.checkButton.isSelected = isAgreed
            })
            .disposed(by: disposeBag)
        
        viewModel.canNext
            .bind(to: bottomButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.agreementSections.enumerated()
            .forEach { (index, item) in
                self.bindMainAgreement(index: index, item: item)
                
                if !item.subAgreements.isEmpty {
                    self.bindSubAgreement(parentIndex: index, parentItem: item)
                }
            }
    }
    
    private func bindMainAgreement(index: Int, item: AgreementSection) {
        item.mainAgreement
            .asDriver()
            .drive(onNext: { [weak self] agreement in
                self?.mainButtons[index]?.checkButton.isSelected = agreement.isChecked
            })
            .disposed(by: disposeBag)
    }
    
    private func bindSubAgreement(parentIndex: Int, parentItem: AgreementSection) {
        parentItem.subAgreements.enumerated()
            .forEach { (subIndex, subItem) in
                subItem
                    .subscribe(onNext: { [weak self] agreement in
                        let index = parentIndex * 10 + subIndex
                        self?.subButtons[index]?.checkButton.isSelected = agreement.isChecked
                    })
                    .disposed(by: disposeBag)
            }
    }
        
    @objc
    private func didTapAllAgreement(sender: UIButton) {
        let isSelected = !sender.isSelected
        viewModel.setAllAgreement(isChecked: isSelected)
    }
    
    @objc
    private func toggleMainAgreement(sender: UIButton) {
        let index = sender.tag
        
        viewModel.toggleMainAgreementWithSub(tag: index, isChecked: !sender.isSelected)
    }
    
    @objc
    private func toggleSubAgreement(sender: UIButton) {
        let index = sender.tag
        let parentIndex = index / 10
        let subIndex = index % 10
        viewModel.toggleSubAgreement(parentTag: parentIndex, subTag: subIndex, isChecked: !sender.isSelected)
    }
    
    @objc
    private func showMainAgreementDetail(sender: UIButton) {
        let index = sender.tag
        let mainAgreement = viewModel.agreementSections[index].mainAgreement.value
        
        showContentfulViewController(agreement: mainAgreement) { [weak self] in
            self?.viewModel.toggleMainAgreementWithSub(tag: index, isChecked: true)
        }
    }
    
    @objc
    private func showSubAgreementDetail(sender: UIButton) {
        let index = sender.tag
        let parentIndex = index / 10
        let subIndex = index % 10
        let subAgreement = viewModel.agreementSections[parentIndex].subAgreements[subIndex].value
        
        showContentfulViewController(agreement: subAgreement) { [weak self] in
            self?.viewModel.toggleSubAgreement(parentTag: parentIndex, subTag: subIndex, isChecked: true)
        }
    }
    
    private func showContentfulViewController(agreement: AgreementItem, completion: @escaping (() -> Void)) {
        //
    }
    
    @objc
    private func didTapNext() {
        self.dismiss(animated: false) { [weak self] in
            self?.confirmCompletion?()
        }
    }
    
    @objc func didTapCancel() {
        self.dismiss(animated: false)
    }
}
