import AppKit

private enum AppLanguage: String {
    case english = "en"
    case traditionalChinese = "zh-Hant"

    static var selected: AppLanguage {
        get {
            guard
                let value = UserDefaults.standard.string(forKey: "appLanguage"),
                let language = AppLanguage(rawValue: value)
            else { return .english }
            return language
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage") }
    }
}

private func T(_ english: String, _ traditionalChinese: String) -> String {
    AppLanguage.selected == .english ? english : traditionalChinese
}

private enum PetState {
    case sitting
    case walking
    case jumping
    case sleeping
    case working
    case bathing
}

private final class PetPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

@MainActor
private final class PetView: NSView {
    weak var controller: PetController?

    private let sittingImage: NSImage
    private let sleepingImage: NSImage
    private let jumpingImage: NSImage
    private let walkingImages: [NSImage]
    private var trackingAreaRef: NSTrackingArea?
    private var lastMousePoint: NSPoint?
    private var pettingDistance: CGFloat = 0
    private var lastPetTime = Date.distantPast
    private var mouseDownWindowOrigin = NSPoint.zero

    var state: PetState = .sitting { didSet { needsDisplay = true } }
    var facingRight = true { didSet { needsDisplay = true } }
    var animationPhase: CGFloat = 0 { didSet { needsDisplay = true } }
    var jumpProgress: CGFloat = 0 { didSet { needsDisplay = true } }
    var heartUntil = Date.distantPast { didSet { needsDisplay = true } }

    init(
        frame: NSRect,
        sitting: NSImage,
        sleeping: NSImage,
        jumping: NSImage,
        walking: [NSImage]
    ) {
        sittingImage = sitting
        sleepingImage = sleeping
        jumpingImage = jumping
        walkingImages = walking
        super.init(frame: frame)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    required init?(coder: NSCoder) { nil }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingAreaRef { removeTrackingArea(trackingAreaRef) }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseMoved, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingAreaRef = area
    }

    private var currentImage: NSImage {
        switch state {
        case .walking:
            return walkingImages[Int(animationPhase * 3.4) % walkingImages.count]
        case .jumping:
            return jumpingImage
        case .sleeping:
            return sleepingImage
        case .sitting, .working, .bathing:
            return sittingImage
        }
    }

    private func fittedRect(for image: NSImage, inside box: NSRect) -> NSRect {
        guard image.size.width > 0, image.size.height > 0 else { return box }
        let ratio = min(box.width / image.size.width, box.height / image.size.height)
        let size = NSSize(width: image.size.width * ratio, height: image.size.height * ratio)
        return NSRect(
            x: box.midX - size.width / 2,
            y: box.minY,
            width: size.width,
            height: size.height
        )
    }

    private var imageRect: NSRect {
        let box: NSRect
        switch state {
        case .walking:
            box = NSRect(x: 5, y: 18 + sin(animationPhase * 2) * 2, width: 320, height: 202)
        case .jumping:
            let progress = min(max(jumpProgress, 0), 1)
            let arc = sin(.pi * progress)
            let crouch = max(0, 1 - progress / 0.14) + max(0, (progress - 0.86) / 0.14)
            box = NSRect(x: 6, y: 16 + arc * 66 - crouch * 3, width: 318, height: 198 - crouch * 8)
        case .sleeping:
            box = NSRect(x: 25, y: 20, width: 280, height: 214)
        case .sitting, .working, .bathing:
            box = NSRect(x: 49, y: 8, width: 232, height: 262)
        }

        var rect = fittedRect(for: currentImage, inside: box)
        let breath = 1 + sin(animationPhase) * (state == .sleeping ? 0.012 : 0.005)
        rect.size.width *= breath
        rect.size.height *= breath
        rect.origin.x = box.midX - rect.width / 2
        rect.origin.y = box.minY
        return rect
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        imageRect.insetBy(dx: -6, dy: -6).contains(point) ? self : nil
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if state == .bathing { drawTubBack() }

        let rect = imageRect
        let shouldMirror = (state == .walking || state == .jumping) && !facingRight
        NSGraphicsContext.current?.saveGraphicsState()
        if shouldMirror {
            let transform = NSAffineTransform()
            transform.translateX(by: rect.maxX, yBy: rect.minY)
            transform.scaleX(by: -1, yBy: 1)
            transform.concat()
            currentImage.draw(
                in: NSRect(x: 0, y: 0, width: rect.width, height: rect.height),
                from: .zero,
                operation: .sourceOver,
                fraction: 1
            )
        } else {
            currentImage.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
        }
        NSGraphicsContext.current?.restoreGraphicsState()

        switch state {
        case .sleeping: drawSleepMarks()
        case .working: drawLaptop()
        case .bathing: drawTubFrontAndWater()
        case .sitting, .walking, .jumping: break
        }

        if heartUntil > Date() { drawHearts() }
    }

    private func drawSleepMarks() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 24, weight: .semibold),
            .foregroundColor: NSColor.systemIndigo.withAlphaComponent(0.78)
        ]
        let lift = (sin(animationPhase) + 1) * 8
        ("z" as NSString).draw(at: NSPoint(x: 238, y: 178 + lift), withAttributes: attributes)
        ("Z" as NSString).draw(at: NSPoint(x: 262, y: 207 + lift), withAttributes: attributes)
    }

    private func drawLaptop() {
        NSColor(calibratedWhite: 0.24, alpha: 0.96).setFill()
        NSBezierPath(roundedRect: NSRect(x: 174, y: 68, width: 105, height: 86), xRadius: 7, yRadius: 7).fill()
        NSColor(calibratedRed: 0.36, green: 0.57, blue: 0.69, alpha: 1).setFill()
        NSBezierPath(roundedRect: NSRect(x: 181, y: 76, width: 91, height: 69), xRadius: 3, yRadius: 3).fill()
        NSColor(calibratedWhite: 0.55, alpha: 1).setFill()
        let keyboard = NSBezierPath()
        keyboard.move(to: NSPoint(x: 163, y: 68))
        keyboard.line(to: NSPoint(x: 279, y: 68))
        keyboard.line(to: NSPoint(x: 300, y: 45))
        keyboard.line(to: NSPoint(x: 179, y: 45))
        keyboard.close()
        keyboard.fill()
    }

    private func drawTubBack() {
        NSColor(calibratedRed: 0.56, green: 0.82, blue: 0.92, alpha: 0.82).setFill()
        NSBezierPath(roundedRect: NSRect(x: 48, y: 14, width: 234, height: 101), xRadius: 38, yRadius: 38).fill()
    }

    private func drawTubFrontAndWater() {
        NSColor(calibratedRed: 0.70, green: 0.91, blue: 0.97, alpha: 0.97).setFill()
        NSBezierPath(roundedRect: NSRect(x: 48, y: 14, width: 234, height: 68), xRadius: 30, yRadius: 30).fill()
        NSColor.white.withAlphaComponent(0.88).setFill()
        [
            NSRect(x: 69, y: 67, width: 26, height: 26),
            NSRect(x: 91, y: 70, width: 19, height: 19),
            NSRect(x: 238, y: 68, width: 25, height: 25),
            NSRect(x: 220, y: 72, width: 18, height: 18)
        ].forEach { NSBezierPath(ovalIn: $0).fill() }
    }

    private func drawHearts() {
        let pulse = 1 + (sin(animationPhase * 3) + 1) * 0.12
        let large: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 28 * pulse, weight: .bold),
            .foregroundColor: NSColor.systemPink.withAlphaComponent(0.94)
        ]
        let small: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 18 * pulse, weight: .bold),
            .foregroundColor: NSColor.systemPink.withAlphaComponent(0.74)
        ]
        ("♥" as NSString).draw(at: NSPoint(x: 242, y: 223), withAttributes: large)
        ("♥" as NSString).draw(at: NSPoint(x: 275, y: 201), withAttributes: small)
    }

    override func mouseMoved(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        defer { lastMousePoint = point }
        guard imageRect.contains(point), let previous = lastMousePoint else { return }
        pettingDistance += hypot(point.x - previous.x, point.y - previous.y)
        let now = Date()
        if pettingDistance > 115, now.timeIntervalSince(lastPetTime) > 0.65 {
            pettingDistance = 0
            lastPetTime = now
            controller?.strokePet()
        }
    }

    override func mouseDown(with event: NSEvent) {
        mouseDownWindowOrigin = window?.frame.origin ?? .zero
        window?.performDrag(with: event)
        guard let window else { return }
        let dx = window.frame.origin.x - mouseDownWindowOrigin.x
        let dy = window.frame.origin.y - mouseDownWindowOrigin.y
        if hypot(dx, dy) < 4 { controller?.tapCat() }
    }

    override func rightMouseDown(with event: NSEvent) {
        controller?.showContextMenu(for: event, in: self)
    }
}

@MainActor
private final class PetController: NSObject {
    private let panel: PetPanel
    private let petView: PetView
    private var timer: Timer?
    private var nextAutoChange = Date().addingTimeInterval(7)
    private var manualUntil = Date.distantPast
    private var movingRight = true
    private var jumpStartedAt: Date?
    private var jumpFollowUpState: PetState = .sitting
    private let jumpDuration: TimeInterval = 1.1
    private var statusItem: NSStatusItem?
    private var hidden = false

    init?(resourcePath: String) {
        let resources = URL(fileURLWithPath: resourcePath)
        let names = ["sit", "sleep", "jump", "walk-1", "walk-2", "walk-3", "walk-4"]
        let images = names.compactMap { NSImage(contentsOf: resources.appendingPathComponent("\($0).png")) }
        guard images.count == names.count else { return nil }

        let size = NSSize(width: 330, height: 280)
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1280, height: 800)
        let savedX = UserDefaults.standard.object(forKey: "catX") as? Double
        let savedY = UserDefaults.standard.object(forKey: "catY") as? Double
        let x = min(max(savedX ?? screen.maxX - size.width - 34, screen.minX), screen.maxX - size.width)
        let y = min(max(savedY ?? screen.minY + 12, screen.minY), screen.maxY - size.height)

        panel = PetPanel(
            contentRect: NSRect(origin: NSPoint(x: x, y: y), size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        petView = PetView(
            frame: NSRect(origin: .zero, size: size),
            sitting: images[0],
            sleeping: images[1],
            jumping: images[2],
            walking: Array(images[3...6])
        )
        super.init()

        petView.controller = self
        panel.contentView = petView
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.acceptsMouseMovedEvents = true
        panel.orderFrontRegardless()

        configureStatusItem()
        startAnimation()
    }

    deinit { timer?.invalidate() }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "🐈"
        item.button?.toolTip = T("Cat Companion", "桌面貓伴")
        item.menu = makeMenu(includeReveal: true)
        statusItem = item
    }

    private func makeMenu(includeReveal: Bool) -> NSMenu {
        let menu = NSMenu(title: T("Cat Companion", "桌面貓伴"))
        addItem(T("Pet", "摸摸牠"), action: #selector(petAction), to: menu)
        menu.addItem(.separator())
        addItem(T("Free Roam", "自由活動"), action: #selector(autoAction), to: menu)
        addItem(T("Walk", "散步"), action: #selector(walkAction), to: menu)
        addItem(T("Jump", "跳一跳"), action: #selector(jumpAction), to: menu)
        addItem(T("Sit", "坐著"), action: #selector(sitAction), to: menu)
        addItem(T("Sleep", "睡覺"), action: #selector(sleepAction), to: menu)
        addItem(T("Work", "工作"), action: #selector(workAction), to: menu)
        addItem(T("Bath", "洗澡"), action: #selector(bathAction), to: menu)
        menu.addItem(.separator())
        menu.addItem(makeLanguageMenuItem())
        menu.addItem(.separator())
        addItem(T("Call Cat Back", "把貓叫回來"), action: #selector(recallAction), to: menu)
        if includeReveal {
            addItem(
                hidden ? T("Show Cat", "顯示貓咪") : T("Hide Temporarily", "暫時隱藏"),
                action: #selector(toggleVisibleAction),
                to: menu
            )
        }
        addItem(T("Quit", "離開"), action: #selector(quitAction), to: menu)
        return menu
    }

    private func makeLanguageMenuItem() -> NSMenuItem {
        let parent = NSMenuItem(title: T("Language", "語言"), action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: T("Language", "語言"))
        let english = NSMenuItem(title: "English", action: #selector(englishAction), keyEquivalent: "")
        english.target = self
        english.state = AppLanguage.selected == .english ? .on : .off
        submenu.addItem(english)
        let chinese = NSMenuItem(title: "繁體中文", action: #selector(chineseAction), keyEquivalent: "")
        chinese.target = self
        chinese.state = AppLanguage.selected == .traditionalChinese ? .on : .off
        submenu.addItem(chinese)
        parent.submenu = submenu
        return parent
    }

    private func addItem(_ title: String, action: Selector, to menu: NSMenu) {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        menu.addItem(item)
    }

    func showContextMenu(for event: NSEvent, in view: NSView) {
        NSMenu.popUpContextMenu(makeMenu(includeReveal: false), with: event, for: view)
    }

    private func startAnimation() {
        let value = Timer(timeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        RunLoop.main.add(value, forMode: .common)
        timer = value
    }

    private func tick() {
        petView.animationPhase += 0.075
        let now = Date()
        if petView.state == .jumping {
            updateJump(at: now)
        } else if petView.state == .walking {
            moveAcrossScreen()
        }
        if now >= nextAutoChange, now >= manualUntil { chooseAutomaticBehavior() }
    }

    private func updateJump(at now: Date) {
        guard let jumpStartedAt else { return }
        let elapsed = now.timeIntervalSince(jumpStartedAt)
        petView.jumpProgress = min(max(CGFloat(elapsed / jumpDuration), 0), 1)
        guard elapsed >= jumpDuration else { return }
        self.jumpStartedAt = nil
        petView.jumpProgress = 0
        petView.state = jumpFollowUpState
    }

    private func moveAcrossScreen() {
        guard let screen = panel.screen ?? NSScreen.main else { return }
        var frame = panel.frame
        frame.origin.x += movingRight ? 1.45 : -1.45
        if frame.maxX >= screen.visibleFrame.maxX {
            frame.origin.x = screen.visibleFrame.maxX - frame.width
            movingRight = false
        } else if frame.minX <= screen.visibleFrame.minX {
            frame.origin.x = screen.visibleFrame.minX
            movingRight = true
        }
        petView.facingRight = movingRight
        panel.setFrameOrigin(frame.origin)
    }

    private func chooseAutomaticBehavior() {
        let roll = Int.random(in: 0..<100)
        if roll < 38 {
            setState(.walking, manualSeconds: 0)
            nextAutoChange = Date().addingTimeInterval(Double.random(in: 7...15))
        } else if roll < 68 {
            setState(.sitting, manualSeconds: 0)
            nextAutoChange = Date().addingTimeInterval(Double.random(in: 7...16))
        } else if roll < 82 {
            startJump(followedBy: .sitting, manualSeconds: 0)
            nextAutoChange = Date().addingTimeInterval(Double.random(in: 4...8))
        } else {
            setState(.sleeping, manualSeconds: 0)
            nextAutoChange = Date().addingTimeInterval(Double.random(in: 18...35))
        }
    }

    private func setState(_ state: PetState, manualSeconds: TimeInterval = 38) {
        jumpStartedAt = nil
        petView.jumpProgress = 0
        petView.state = state
        if manualSeconds > 0 {
            manualUntil = Date().addingTimeInterval(manualSeconds)
            nextAutoChange = manualUntil
        }
    }

    private func startJump(followedBy state: PetState, manualSeconds: TimeInterval) {
        jumpFollowUpState = state
        jumpStartedAt = Date()
        petView.jumpProgress = 0
        petView.state = .jumping
        if manualSeconds > 0 {
            manualUntil = Date().addingTimeInterval(manualSeconds)
            nextAutoChange = manualUntil
        }
    }

    func strokePet() { petView.heartUntil = Date().addingTimeInterval(2.2) }

    func tapCat() {
        strokePet()
        startJump(followedBy: .walking, manualSeconds: 8)
        nextAutoChange = Date().addingTimeInterval(8)
    }

    func savePosition() {
        UserDefaults.standard.set(panel.frame.origin.x, forKey: "catX")
        UserDefaults.standard.set(panel.frame.origin.y, forKey: "catY")
    }

    @objc private func petAction() { strokePet() }
    @objc private func walkAction() { setState(.walking) }
    @objc private func jumpAction() { startJump(followedBy: .sitting, manualSeconds: 3) }
    @objc private func sitAction() { setState(.sitting) }
    @objc private func sleepAction() { setState(.sleeping) }
    @objc private func workAction() { setState(.working) }
    @objc private func bathAction() { setState(.bathing) }
    @objc private func autoAction() { manualUntil = .distantPast; nextAutoChange = Date() }
    @objc private func englishAction() { switchLanguage(to: .english) }
    @objc private func chineseAction() { switchLanguage(to: .traditionalChinese) }

    private func switchLanguage(to language: AppLanguage) {
        AppLanguage.selected = language
        statusItem?.button?.toolTip = T("Cat Companion", "桌面貓伴")
        statusItem?.menu = makeMenu(includeReveal: true)
    }

    @objc private func recallAction() {
        guard let screen = NSScreen.main else { return }
        hidden = false
        panel.setFrameOrigin(NSPoint(
            x: screen.visibleFrame.midX - panel.frame.width / 2,
            y: screen.visibleFrame.minY + 12
        ))
        panel.orderFrontRegardless()
        setState(.sitting, manualSeconds: 5)
        statusItem?.menu = makeMenu(includeReveal: true)
    }

    @objc private func toggleVisibleAction() {
        hidden.toggle()
        if hidden { panel.orderOut(nil) } else { panel.orderFrontRegardless() }
        statusItem?.menu = makeMenu(includeReveal: true)
    }

    @objc private func quitAction() {
        savePosition()
        NSApplication.shared.terminate(nil)
    }
}

@MainActor
private final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controller: PetController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        guard let path = Bundle.main.resourcePath, let controller = PetController(resourcePath: path) else {
            let alert = NSAlert()
            alert.messageText = T("Could Not Load Pet Sprites", "無法載入寵物素材")
            alert.informativeText = T("Rebuild the app with all seven PNG files.", "請使用完整七張 PNG 重新建立 App。")
            alert.runModal()
            NSApplication.shared.terminate(nil)
            return
        }
        self.controller = controller
    }

    func applicationWillTerminate(_ notification: Notification) {
        controller?.savePosition()
    }
}

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    withExtendedLifetime(delegate) { app.run() }
}
