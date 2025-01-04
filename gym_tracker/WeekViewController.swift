import SwiftUI
import FSCalendar

struct FSCalendarWeekView: UIViewRepresentable {
    let highlightedDates: [Date]
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        let highlightedDates: [Date]
        
        init(highlightedDates: [Date]) {
            self.highlightedDates = highlightedDates
        }
        
        func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
            calendar.frame = CGRect(origin: calendar.frame.origin, size: bounds.size)
        }
        
        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            return false
        }
        
        func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            let cell = calendar.dequeueReusableCell(withIdentifier: "CustomCell", for: date, at: position) as! CustomFSCalendarCell
            let isToday = Calendar.current.isDateInToday(date)
            
            if highlightedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                cell.checkmarkLabel.isHidden = false
                cell.titleLabel.isHidden = true
                cell.contentView.backgroundColor = .systemGreen
            } else {
                cell.checkmarkLabel.isHidden = true
                cell.titleLabel.isHidden = false
                cell.contentView.backgroundColor = .clear
            }
            
            cell.configureCell(isToday: isToday)
            return cell
        }
        
    }
    
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        
        calendar.scope = .week
        calendar.headerHeight = 0
        calendar.rowHeight = 44
        calendar.weekdayHeight = 0
        
            
        calendar.adjustsBoundingRectWhenChangingMonths = false
        calendar.clipsToBounds = true
        calendar.contentView.clipsToBounds = true
        calendar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 0)
        calendar.appearance.headerDateFormat = ""
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 16)
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 0)
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.selectionColor = .clear // No color for selected dates
        calendar.appearance.todayColor = .clear
        calendar.appearance.titleDefaultColor = .white
        calendar.appearance.titleTodayColor = .white
        
        // Disable swiping to expand the calendar
        calendar.scopeGesture.isEnabled = false
        
        // Register custom cell
        calendar.register(CustomFSCalendarCell.self, forCellReuseIdentifier: "CustomCell")
        
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.reloadData() // Refresh the calendar view
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(highlightedDates: highlightedDates)
    }

}

