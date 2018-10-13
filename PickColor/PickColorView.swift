import Foundation

public class PickColorView: UIView {

    public let colorMapControl: ColorMapControl

    public let toolbarControl: ToolbarColorControl

    public init() {
        let startColor = UIColor(hexString: "#bfffa5")!

        colorMapControl = ColorMapControl(color: startColor)
        colorMapControl.translatesAutoresizingMaskIntoConstraints = false

        toolbarControl = ToolbarColorControl(color: startColor)
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
        colorMapControl.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        colorMapControl.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        colorMapControl.addTarget(self, action: #selector(colorMapChangedColor), for: .valueChanged)
        toolbarControl.addTarget(self, action: #selector(toolbarChangedColor), for: .valueChanged)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func colorMapChangedColor() {
//        print("ColorMap => \(colorMapControl.color.hex)")
        toolbarControl.color = colorMapControl.color
    }

    @objc func toolbarChangedColor() {
//        print("ColorToolbar => \(toolbarControl.color.hex)")
        colorMapControl.color = toolbarControl.color
    }

}
