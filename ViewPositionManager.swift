import SwiftUI

class ViewPositionManager: ObservableObject {
    @Published var positions: [UUID: CGRect] = [:]

    func getNonOverlappingPosition(for proposedFrame: CGRect, in gridSize: CGSize) -> CGRect {
        let cellWidth: CGFloat = 300
        let cellHeight: CGFloat = 400
        var newFrame = proposedFrame

        // Horizontal and vertical steps match grid cell size
        let horizontalStep = cellWidth
        let verticalStep = cellHeight

        // Try to place within grid bounds initially
        newFrame = CGRect(
            x: min(newFrame.origin.x, gridSize.width - newFrame.width),
            y: min(newFrame.origin.y, gridSize.height - newFrame.height),
            width: cellWidth,
            height: cellHeight
        )

        var positionFound = false

        // Iterate through potential positions
        for y in stride(from: 0, to: gridSize.height, by: verticalStep) {
            for x in stride(from: 0, to: gridSize.width, by: horizontalStep) {
                newFrame.origin = CGPoint(x: x, y: y)
                if !isIntersecting(with: newFrame) {
                    positionFound = true
                    break
                }
            }
            if positionFound { break }
        }

        // If no non-overlapping position is found, use the original proposed frame
        return positionFound ? newFrame : proposedFrame
    }

    private func isIntersecting(with frame: CGRect) -> Bool {
        for (_, existingFrame) in positions {
            if frame.intersects(existingFrame) {
                return true
            }
        }
        return false
    }

    func setPosition(id: UUID, frame: CGRect) {
        positions[id] = frame
    }
}
