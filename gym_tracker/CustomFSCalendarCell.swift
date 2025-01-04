import FSCalendar

class CustomFSCalendarCell: FSCalendarCell {
    let checkmarkLabel = UILabel()
    private let padding: CGFloat = 5.0 // General padding for cell content
    private let todayPadding: CGFloat = 8.0 // Extra padding for today cell
    private var isToday: Bool = false // Indicates if the cell is for today
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Configure the checkmark label
        checkmarkLabel.translatesAutoresizingMaskIntoConstraints = false
        checkmarkLabel.text = "✓"
        checkmarkLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        checkmarkLabel.textAlignment = .center
        checkmarkLabel.textColor = .white
        contentView.addSubview(checkmarkLabel)
        
        // Configure the contentView with rounded corners
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = false // Allow shadow to show outside bounds
        
        // Add shadow for today
        contentView.layer.shadowColor = UIColor.blue.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        // Set constraints for contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding), // Left padding
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding), // Right padding
            contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: -padding), // No vertical padding
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: padding),
            
            // Center the checkmark label
            checkmarkLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            checkmarkLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(isToday: Bool) {
        self.isToday = isToday
        
        // If it's the current day, apply extra padding and show the border
        if isToday {
            contentView.backgroundColor = .clear // Transparent background
            contentView.layer.borderColor = UIColor.systemBlue.cgColor
            contentView.layer.borderWidth = 2
            contentView.layer.shadowOpacity = 0.5 // Apply shadow
            // Add extra padding for today
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding).isActive = true;
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding).isActive = true;
            contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: -padding).isActive = true;
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: padding).isActive = true;
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.shadowOpacity = 0 // Remove shadow for non-today cells
            // Reset padding for non-today cells
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding).isActive = true
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding).isActive = true
        }
    }
}
