import UIKit

final class StatisticTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let borderView: UIView = {
        let borderView = UIView()
        borderView.layer.cornerRadius = 16
        borderView.backgroundColor = .blue
        borderView.translatesAutoresizingMaskIntoConstraints = false
        return borderView
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.colorSelection1.cgColor, UIColor.colorSelection9.cgColor, UIColor.colorSelection3.cgColor]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 16
        return gradientLayer
    }()
    
    private let insideView: UIView = {
        let insideView = UIView()
        insideView.layer.cornerRadius = 16
        insideView.backgroundColor = .white
        insideView.translatesAutoresizingMaskIntoConstraints = false
        return insideView
    }()
    
    private func setupViews() {
        contentView.addSubview(borderView)
        contentView.addSubview(insideView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        detailLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        borderView.layer.addSublayer(gradientLayer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            insideView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 1),
            insideView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 1),
            insideView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -1),
            insideView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -1),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            contentView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = borderView.bounds
    }
    
    func configure(with statistic: Statistic) {
        titleLabel.text = statistic.value
        detailLabel.text = statistic.title
    }
}

