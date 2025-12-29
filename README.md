<p align="center">
  <img src="logo.png" width="456">
</p>

<p align="center">
  <a href="README_CN.md">中文文档</a>
</p>

FlowRouter is a UIKit-based routing iOS component designed to simplify page navigation and data passing in iOS applications. By using custom route names, developers can more flexibly wrap ViewControllers into easy-to-understand routing interfaces, thereby avoiding the complex navigation operations such as push and present in traditional UIKit.

## Key Features

### Simplest route navigation and return operations:
- **Navigate to a new interface**: Just one line of code `FlowRouter.open(.yourCustomRouterName)` to navigate to a new interface, without handling complex push, present and other operations


```
FlowRouter.open(.yourCustomRouterName)
```

- **Exit current interface**: Just one line of code `FlowRouter.pop()` to exit the current interface, without handling complex navigation stack operations


```
FlowRouter.pop()
```

1. **Simplified navigation operations**: Use custom route names for page navigation, without directly handling complex navigation operations such as push, present, etc.

2. **Parameter passing**: Supports passing parameters during page navigation, as well as returning data to the caller when the page closes

3. **Lifecycle monitoring**: Supports monitoring the entire lifecycle of routes, using `await` syntax to get page return data

4. **Data return functionality**: Supports passing data to the returning page when the page closes, enabling bidirectional communication between pages

5. **Custom transition animations**: Supports custom page enter/exit animations, only used in present mode

6. **Route merging**: Supports merging multiple route operations into a single route operation

7. **Interceptor slice operations**: Supports unified statistics, interruption or modification operations for certain routes

## Installation

### Swift Package Manager (SPM)

In Xcode, select `File` → `Add Package Dependencies`, then enter the repository URL:

```
https://github.com/xiaoxiaowesley/FlowRouter.git
```

Or add the dependency in the `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/xiaoxiaowesley/FlowRouter.git", from: "1.0.0")
]
```

### Using in your project

1. Remove the default Main.storyboard

    Select the target
    Find Info → Application Scene Manifest → Scene Configuration
    Delete:
    Storyboard Name
    Main storyboard file base name

2. Configure route mapping

```
extension Router.Scheme {
    /// 1. Declare route
    static let root = Router.Scheme("myScheme://root")
    static let home = Router.Scheme("myScheme://home")
    
    /// 2. Route + ViewController binding
    static public func schemeMap() -> [Router.Scheme: AnyClass] {
        let map: [Router.Scheme: AnyClass] = [
                .root: RootViewController.self,
                .home: HomeViewController.self,
        ]
        return map
    }
    
    @MainActor
    static public func schemeActionMap() -> [Router.Scheme: RouteAction] {
        return [:]
    }
}
```

3. Register routes in SceneDelegate

```
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
            
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let root = RootViewController.shared
        root.window = window
        window.rootViewController = root
        window.makeKeyAndVisible()

        // Iterate through all Router.schemeMap(), get the rawValue of the key, keep the value unchanged, and generate a new map
        let stringVCMap = Dictionary<String, AnyClass>(
            uniqueKeysWithValues: Router.Scheme.schemeMap().map { (key, value) -> (String, AnyClass) in
                return (key.rawValue, value)
            })
        let stringActionMap = Dictionary<String, RouteAction>(
            uniqueKeysWithValues: Router.Scheme.schemeActionMap().map { (key, value) -> (String, RouteAction) in
                return (key.rawValue, value)
            })

        RouterModule.shared.register(
            stringVCMap,
            stringActionMap,
            rootViewController: RootViewController.shared,
            navigationController: RootViewController.shared.naviController!
        )
    }
```

## Advanced Features

### FlowRouter Data Return Functionality

FlowRouter supports passing data to the returning page when the page closes. This enables bidirectional communication between pages, allowing the current page to pass processing results or other data to the previous page.

#### Core functionality code

##### 1. Pass data from current page back to previous page

When calling the `FlowRouter.pop()` method in the current page, you can pass in a dictionary parameter, which will be passed as return data to the previous page:

```swift
// Pass data back to previous page
FlowRouter.pop(["result": "success", "data": ["id": 123, "name": "example"]])
```

##### 2. Receive return data in the previous page

In the page that needs to receive return data, use the `FlowRouter.awaitOpen()` method to open a new page, which will wait for the new page to close and return data:

```swift
Task {
    let result = await FlowRouter.awaitOpen(.uikit)
    // Process the returned result
    print("Received result: \(result)")
}
```

### FlowRouter supports custom page transition animations

Allows developers to implement unique page enter and exit effects. By implementing the `UIViewControllerTransitioningDelegate` protocol, custom animation effects can be specified for page navigation.

#### Core functionality code

##### 1. Open page with custom transition animation

In the page that needs to use custom transition animation, specify the navigation type as custom transition through `RouteOption` and pass in the current page as the transition delegate:

```swift
// Open page with custom transition animation
FlowRouter.open(.uikit, [:], RouteOption(navigationType: .present(.custom, self)))
```

##### 2. Implement UIViewControllerTransitioningDelegate protocol

Implement the `UIViewControllerTransitioningDelegate` protocol in the page controller to provide a custom transition animation controller:

```swift
extension YourViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Return custom presentation animation controller
        return YourCustomPresentAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Return custom dismissal animation controller
        return YourCustomDismissAnimator()
    }
}
