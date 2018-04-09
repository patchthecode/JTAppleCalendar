//
//  JTAppleCalendarView.swift
//
//  Copyright (c) 2016-2017 JTAppleCalendar (https://github.com/patchthecode/JTAppleCalendar)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

let maxNumberOfDaysInWeek = 7 // Should not be changed
let maxNumberOfRowsPerMonth = 6 // Should not be changed
let developerErrorMessage = "There was an error in this code section. Please contact the developer on GitHub"
let decorationViewID = "Are you ready for the life after this one?"
let errorDelta: CGFloat = 0.0000001


/// An instance of JTAppleCalendarView (or simply, a calendar view) is a
/// means for displaying and interacting with a gridstyle layout of date-cells
open class JTAppleCalendarView: UICollectionView {
    
    /// Configures the size of your date cells
    @IBInspectable open var cellSize: CGFloat = 0 {
        didSet {
            if oldValue == cellSize { return }
            if scrollDirection == .horizontal {
                calendarViewLayout.cellSize.width = cellSize
            } else {
                calendarViewLayout.cellSize.height = cellSize
            }
            calendarViewLayout.invalidateLayout()
            calendarViewLayout.itemSizeWasSet = cellSize == 0 ? false: true
        }
    }
    
    /// The scroll direction of the sections in JTAppleCalendar.
    open var scrollDirection: UICollectionViewScrollDirection!
    
    /// Enables/Disables the stretching of date cells. When enabled cells will stretch to fit the width of a month in case of a <= 5 row month.
    open var allowsDateCellStretching = true
    
    /// Alerts the calendar that range selection will be checked. If you are
    /// not using rangeSelection and you enable this,
    /// then whenever you click on a datecell, you may notice a very fast
    /// refreshing of the date-cells both left and right of the cell you
    /// just selected.
    open var isRangeSelectionUsed: Bool = false
    
    /// The object that acts as the delegate of the calendar view.
    weak open var calendarDelegate: JTAppleCalendarViewDelegate? {
        didSet { lastMonthSize = sizesForMonthSection() }
    }
    
    /// The object that acts as the data source of the calendar view.
    weak open var calendarDataSource: JTAppleCalendarViewDataSource? {
        didSet { setupMonthInfoAndMap() } // Refetch the data source for a data source change
    }
    
    var lastSavedContentOffset: CGFloat    = 0.0
    var triggerScrollToDateDelegate: Bool? = true
    var isScrollInProgress                 = false
    var isReloadDataInProgress             = false
    
    // keeps track of if didEndScroll is not yet completed. If isStillScrolling
    var didEndScollCount = 0
    // Keeps track of scroll target location. If isScrolling, and user taps while scrolling
    var endScrollTargetLocation: CGFloat = 0
    
    var generalDelayedExecutionClosure: [(() -> Void)] = []
    var scrollDelayedExecutionClosure: [(() -> Void)]  = []
    
    let dateGenerator = JTAppleDateConfigGenerator()
    
    /// Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
    public init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        setupNewLayout(from: collectionViewLayout as! JTAppleCalendarLayoutProtocol)
    }
    
    /// Initializes and returns a newly allocated collection view object with the specified frame and layout.
    @available(*, unavailable, message: "Please use JTAppleCalendarView() instead. It manages its own layout.")
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        setupNewLayout(from: collectionViewLayout as! JTAppleCalendarLayoutProtocol)
    }
    
    /// Initializes using decoder object
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNewLayout(from: collectionViewLayout as! JTAppleCalendarLayoutProtocol)
    }
    
    // Configuration parameters from the dataSource
    var cachedConfiguration: ConfigurationParameters!
    // Set the start of the month
    var startOfMonthCache: Date!
    // Set the end of month
    var endOfMonthCache: Date!
    var selectedCellData: [IndexPath:SelectedCellData] = [:]
    var pathsToReload: Set<IndexPath> = [] //Paths to reload because of prefetched cells
    
    var anchorDate: Date?
    
    var requestedContentOffset: CGPoint {
        var retval: CGPoint = .zero
        guard let date = anchorDate else { return retval }
        
        // reset the initial scroll date once used.
        anchorDate = nil
        
        // Ensure date is within valid boundary
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let firstDayOfDate = calendar.date(from: components)!
        if !((firstDayOfDate >= startOfMonthCache!) && (firstDayOfDate <= endOfMonthCache!)) { return retval }
        
        // Get valid indexPath of date to scroll to
        let retrievedPathsFromDates = pathsFromDates([date])
        if retrievedPathsFromDates.isEmpty { return retval }
        let sectionIndexPath = pathsFromDates([date])[0]
        
        
        if calendarViewLayout.thereAreHeaders && scrollDirection == .vertical {
            let indexPath = IndexPath(item: 0, section: sectionIndexPath.section)
            guard let attributes = calendarViewLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath) else { return retval }
            
            let maxYCalendarOffset = max(0, self.contentSize.height - self.frame.size.height)
            retval = CGPoint(x: attributes.frame.origin.x,y: min(maxYCalendarOffset, attributes.frame.origin.y))
            //            if self.scrollDirection == .horizontal { topOfHeader.x += extraAddedOffset} else { topOfHeader.y += extraAddedOffset }
            
        } else {
            switch scrollingMode {
            case .stopAtEach, .stopAtEachSection, .stopAtEachCalendarFrame:
                if scrollDirection == .horizontal || (scrollDirection == .vertical && !calendarViewLayout.thereAreHeaders) {
                    retval = self.targetPointForItemAt(indexPath: sectionIndexPath) ?? .zero
                }
            default:
                break
            }
        }
        return retval
    }
    
    open var sectionInset: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    open var minimumInteritemSpacing: CGFloat = 0
    open var minimumLineSpacing: CGFloat = 0
    
    lazy var theData: CalendarData = {
        return self.setupMonthInfoDataForStartAndEndDate()
    }()
    
    var lastMonthSize: [AnyHashable:CGFloat] = [:]
    
    var monthMap: [Int: Int] {
        get { return theData.sectionToMonthMap }
        set { theData.sectionToMonthMap = monthMap }
    }

    var decelerationRateMatchingScrollingMode: CGFloat {
        switch scrollingMode {
        case .stopAtEachCalendarFrame: return UIScrollViewDecelerationRateFast
        case .stopAtEach, .stopAtEachSection: return UIScrollViewDecelerationRateFast
        case .nonStopToSection, .nonStopToCell, .nonStopTo, .none: return UIScrollViewDecelerationRateNormal
        }
    }

    /// Configure the scrolling behavior
    open var scrollingMode: ScrollingMode = .stopAtEachCalendarFrame {
        didSet {
            decelerationRate = decelerationRateMatchingScrollingMode
            #if os(iOS)
                switch scrollingMode {
                case .stopAtEachCalendarFrame:
                    isPagingEnabled = true
                default:
                    isPagingEnabled = false
                }
            #endif
        }
    }
}

@available(iOS 9.0, *)
extension JTAppleCalendarView {
    /// A semantic description of the view’s contents, used to determine whether the view should be flipped when switching between left-to-right and right-to-left layouts.
    
    open override var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            transform.a = semanticContentAttribute == .forceRightToLeft ? -1 : 1
        }
    }
}
