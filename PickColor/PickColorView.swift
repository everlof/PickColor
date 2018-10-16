import Foundation

public class PickColorView: UIView, ToolbarViewDelegate {

    public let colorMapControl: ColorMapControl

    public let toolbarControl: ToolbarView

    public var selectedColor: UIColor {
        return toolbarControl.selectedColor
    }

    public init() {
        let startColor = UIColor(hexString: "#bfffa5")!

        colorMapControl = ColorMapControl(color: startColor)
        colorMapControl.translatesAutoresizingMaskIntoConstraints = false

        toolbarControl = ToolbarView(selectedColor: startColor)
        toolbarControl.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)
        backgroundColor = .white

        addSubview(toolbarControl)
        addSubview(colorMapControl)

        toolbarControl.topAnchor.constraint(equalTo: topAnchor).isActive = true
        toolbarControl.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        toolbarControl.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        colorMapControl.topAnchor.constraint(equalTo: toolbarControl.bottomAnchor).isActive = true

        colorMapControl.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        colorMapControl.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        colorMapControl.addTarget(self, action: #selector(colorMapChangedColor), for: .valueChanged)
        toolbarControl.delegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func colorMapChangedColor() {
        toolbarControl.selectedColor = colorMapControl.color
    }

    // MARK: - ToolbarViewDelegate

    public func toolbarView(_: ToolbarView, didPick color: UIColor) {
        Persistance.save(color: color)
    }

    public func toolbarView(_ toolbarView: ToolbarView, didUpdateHue hue: CGFloat) {
        colorMapControl.hue = hue
    }

    public func toolbarView(_ toolbarView: ToolbarView, didSelectRecentColor color: UIColor) {
        colorMapControl.color = color
    }

    public func toolbarView(_ toolbarView: ToolbarView, didManuallyEnterColor color: UIColor) {
        colorMapControl.color = color
    }

}
