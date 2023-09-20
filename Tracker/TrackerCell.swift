import UIKit

final class TrackerCell: UICollectionViewCell {
    var nameLabel: UILabel!
    var emojiLabel: UILabel!
    var tracker: Tracker?
    var addButton: UIButton!
    var addButtonTapped: (() -> Void)?
    var daysLabel: UILabel!
    var getDaysCount: ((UUID) -> Int)?

    var cardView: UIView!
    var trackerView: UIView!
    var daysView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCardView()
        setupTrackerView()
        setupDaysView()
        setupEmojiLabel()
        setupAddButton()
        setupNameLabel()
        setupDaysLabel()

        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCardView() {
        cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func setupTrackerView() {
        trackerView = UIView()
        trackerView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(trackerView)
        trackerView.layer.cornerRadius = 16
          
        NSLayoutConstraint.activate([
            trackerView.topAnchor.constraint(equalTo: cardView.topAnchor),
            trackerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            trackerView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }

    private func setupDaysView() {
        daysView = UIView()
        daysView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(daysView)
        daysView.backgroundColor = .white
        daysView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        daysView.layer.cornerRadius = 16

        NSLayoutConstraint.activate([
            daysView.topAnchor.constraint(equalTo: trackerView.bottomAnchor),
            daysView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            daysView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            daysView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupEmojiLabel() {
        emojiLabel = UILabel()
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerView.addSubview(emojiLabel)
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        emojiLabel.layer.cornerRadius = 20
        emojiLabel.font = UIFont.systemFont(ofSize: 16)
        emojiLabel.clipsToBounds = true

        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 10),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 10),
            emojiLabel.widthAnchor.constraint(equalToConstant: 40),
            emojiLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupAddButton() {
        addButton = UIButton(type: .system)
        addButton.setTitle("+", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        daysView.addSubview(addButton)
        addButton.layer.cornerRadius = 20
        addButton.setTitleColor(.white, for: .normal)

        NSLayoutConstraint.activate([
            addButton.centerYAnchor.constraint(equalTo: daysView.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: daysView.trailingAnchor, constant: -10),
            addButton.widthAnchor.constraint(equalToConstant: 40),
            addButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        addButton.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
    }

    @objc private func handleButtonTap() {
        addButtonTapped?()
    }

    private func setupNameLabel() {
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerView.addSubview(nameLabel)
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 2
        
        NSLayoutConstraint.activate([
            nameLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -10),
            nameLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -10)
        ])

    }
    
    private func setupDaysLabel() {
        daysLabel = UILabel()
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysView.addSubview(daysLabel)
        daysLabel.textColor = .black

        NSLayoutConstraint.activate([
            daysLabel.centerYAnchor.constraint(equalTo: daysView.centerYAnchor),
            daysLabel.leadingAnchor.constraint(equalTo: daysView.leadingAnchor, constant: 10)
        ])
    }

    func configure(with tracker: Tracker) {
        self.tracker = tracker
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        if let daysCount = getDaysCount?(tracker.id) {
            daysLabel.text = daysText(for: daysCount)
        }

        cardView.backgroundColor = tracker.color
        addButton.backgroundColor = tracker.color
    }
    
    func daysText(for days: Int) -> String {
        switch days {
        case 1:
            return "\(days) день"
        case 2...4:
            return "\(days) дня"
        default:
            return "\(days) дней"
        }
    }
}

