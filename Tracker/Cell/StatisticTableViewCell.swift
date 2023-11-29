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
    
    override func layoutSubviews() {
            super.layoutSubviews()
            applyRainbowBorder(to: contentView, borderWidth: 2)

            let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            contentView.frame = contentView.frame.inset(by: insets)
        }
    
    private func setupViews() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
               titleLabel.translatesAutoresizingMaskIntoConstraints = false
               contentView.addSubview(titleLabel)
               

               detailLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
               detailLabel.translatesAutoresizingMaskIntoConstraints = false
               contentView.addSubview(detailLabel)
               
               contentView.layer.cornerRadius = 12
               contentView.layer.borderWidth = 1
               contentView.backgroundColor = .white
               contentView.clipsToBounds = true
           }
    
    private func setupConstraints() {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                
                detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                
                contentView.heightAnchor.constraint(equalToConstant: 90),
                contentView.widthAnchor.constraint(equalToConstant: 343)
            ])
        }
        
        func configure(with statistic: Statistic) {
            titleLabel.text = statistic.value
            detailLabel.text = statistic.title
        }
    
    private func applyRainbowBorder(to view: UIView, borderWidth: CGFloat) {

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: CGSize(width: view.bounds.width + borderWidth * 2, height: view.bounds.height + borderWidth * 2))
        gradientLayer.colors = [
            UIColor.red.cgColor,
            UIColor.orange.cgColor,
            UIColor.yellow.cgColor,
            UIColor.green.cgColor,
            UIColor.blue.cgColor,
            UIColor.purple.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        let shape = CAShapeLayer()
        shape.lineWidth = borderWidth
        shape.path = UIBezierPath(rect: view.bounds).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradientLayer.mask = shape


        UIGraphicsBeginImageContextWithOptions(gradientLayer.bounds.size, false, 0.0)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: -borderWidth, y: -borderWidth, width: view.bounds.width + borderWidth * 2, height: view.bounds.height + borderWidth * 2)
        borderLayer.contents = gradientImage?.cgImage

        view.layer.addSublayer(borderLayer)
        view.layer.masksToBounds = true
    }

    }
