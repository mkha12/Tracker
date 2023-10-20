import UIKit


final class OnboardingPageController: UIViewController {
    
    var imageView = UIImageView()
    var titleLabel = UILabel()
    var descriptionLabel = UILabel()
    var index: Int?
    var completionHandler: (() -> Void)?
    
    var page: OnboardingPage? {
        didSet {
            updateUI()
        }
    }
    
    let continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        return button
    }()

    
    func updateUI() {
        imageView.image = page?.image
        titleLabel.text = page?.title
        descriptionLabel.text = page?.description
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateUI()
    }
    
    
    @objc func handleContinue() {
        if let currentIndex = index, currentIndex < (parent as! OnboardingViewController).pages.count - 1 {
            let nextVC = (parent as! OnboardingViewController).viewController(at: currentIndex + 1)
            (parent as! OnboardingViewController).setViewControllers([nextVC!], direction: .forward, animated: true, completion: nil)
        } else {
            let trackersVC = MainTabBarController()
            
            UIApplication.shared.windows.first?.rootViewController = trackersVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }


    
    func setupUI() {
        // ImageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
           imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
           imageView.clipsToBounds = true
           view.addSubview(imageView)
        
        // TitleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 2
          titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
          titleLabel.textColor = .blackDay
          titleLabel.textAlignment = .center
          view.addSubview(titleLabel)
        
        // DescriptionLabel
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
           descriptionLabel.font = UIFont.systemFont(ofSize: 16)
           descriptionLabel.numberOfLines = 0
           descriptionLabel.textColor = .white
           descriptionLabel.textAlignment = .center
           view.addSubview(descriptionLabel)
        
        
        view.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.backgroundColor = .blackDay
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        
        // AutoLayout
        NSLayoutConstraint.activate([
            
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}


