//
//  JTAppleCalendarLayoutProtocol.swift
//  JTAppleCalendar
//
//  Created by JayT on 2016-10-02.
//
//


protocol JTAppleCalendarLayoutProtocol: class {
    var itemSize: CGSize {get set}
    var headerReferenceSize: CGSize {get set}
    var scrollDirection: UICollectionViewScrollDirection {get set}
    var cellCache: [Int: [UICollectionViewLayoutAttributes]] {get set}
    var headerCache: [Int: UICollectionViewLayoutAttributes] {get set}
    var sectionSize: [CGFloat] {get set}
    func targetContentOffsetForProposedContentOffset(
        _ proposedContentOffset: CGPoint) -> CGPoint
    func sectionFromRectOffset(_ offset: CGPoint) -> Int
    func sectionFromOffset(_ theOffSet: CGFloat) -> Int
    func sizeOfContentForSection(_ section: Int) -> CGFloat
    func clearCache()
    func prepare()
}
