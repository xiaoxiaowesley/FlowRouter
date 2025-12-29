
<p align="center">
  <img src="logo.png" width="456">
</p>
<p align="center">
  <a href="README.md">English </a>
</p>

FlowRouter 是一个基于 UIKit 的路由 iOS 组件，旨在简化 iOS 应用中的页面导航和数据传递。通过使用自定义的路由名，开发者可以更灵活地将 ViewController 包装成易于理解的路由接口，从而避免传统 UIKit 中 push、present 等繁杂的导航操作.

## 主要特性

### 最简单的路由跳转和返回操作：
- **跳转到新界面**：只需一行代码 `FlowRouter.open(.yourCustomRouterName)` 即可跳转到新界面，无需处理复杂的 push、present 等操作


```
FlowRouter.open(.yourCustomRouterName)
```

- **退出当前界面**：只需一行代码 `FlowRouter.pop()` 即可退出当前界面，无需处理复杂的导航栈操作


```
FlowRouter.pop()
```

1. **简化导航操作**：使用自定义的路由名进行页面跳转，无需直接处理 push、present 等复杂的导航操作

2. **参数传递**：支持在页面跳转时传递参数，以及在页面关闭时向调用方返回数据

3. **生命周期监听**：支持监听路由的整个生命周期，通过 `await` 语法获取页面返回的数据

4. **数据返回功能**：支持在页面关闭时向返回的页面传递数据，实现页面间的双向通信

5. **自定义转场动画**：支持自定义页面进/退场动画，仅在 present 模式下使用

6. **路由合并**：支持将多个路由操作合并成一个路由操作

7. **Interceptor 切片操作**：支持对某些路由进行统一的统计、中断或修改操作

## 安装方法

### Swift Package Manager (SPM)

在 Xcode 中，选择 `File` → `Add Package Dependencies`，然后输入仓库地址：

```
https://github.com/xiaoxiaowesley/FlowRouter.git
```

或者在 `Package.swift` 文件中添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/xiaoxiaowesley/FlowRouter.git", from: "1.0.0")
]
```

### 在项目中使用

1. 移除默认的 Main.storyboard

    选中 target
    找到 Info → Application Scene Manifest → Scene Configuration
    删除：
    Storyboard Name
    Main storyboard file base name

2. 配置路由映射

```
extension Router.Scheme {
    /// 1. 声明路由
    static let root = Router.Scheme("myScheme://root")
    static let home = Router.Scheme("myScheme://home")
    
    /// 2.路由+ViewController 绑定
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

3. 在 SceneDelegate 中注册路由

```
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
            
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let root = RootViewController.shared
        root.window = window
        window.rootViewController = root
        window.makeKeyAndVisible()

        // 遍历所有的Router.schemeMap(),把key获取rawValue，value保持不变，生成一个新的map
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

## 进阶功能

### FlowRouter 返回数据功能

FlowRouter 支持在页面关闭时向返回的页面传递数据。这使得页面之间可以实现双向通信，当前页面可以将处理结果或其他数据传递给上一个页面。

#### 核心功能代码

##### 1. 从当前页面传递数据回上一个页面

在当前页面调用 `FlowRouter.pop()` 方法时，可以传入一个字典参数，该字典将作为返回数据传递给上一个页面：

```swift
// 传递数据回上一个页面
FlowRouter.pop(["result": "success", "data": ["id": 123, "name": "example"]])
```

##### 2. 在上一个页面接收返回的数据

在需要接收返回数据的页面中，使用 `FlowRouter.awaitOpen()` 方法打开新页面，该方法会等待新页面关闭并返回数据：

```swift
Task {
    let result = await FlowRouter.awaitOpen(.uikit)
    // 处理返回的结果
    print("Received result: \(result)")
}
```

### FlowRouter 支持自定义页面转场动画

允许开发者实现独特的页面进入和退出效果。通过实现 `UIViewControllerTransitioningDelegate` 协议，可以为页面跳转指定自定义的动画效果。

#### 核心功能代码

##### 1. 使用自定义转场动画打开页面

在需要使用自定义转场动画的页面中，通过 `RouteOption` 指定导航类型为自定义转场，并传入当前页面作为转场代理：

```swift
// 使用自定义转场动画打开页面
FlowRouter.open(.uikit, [:], RouteOption(navigationType: .present(.custom, self)))
```

##### 2. 实现 UIViewControllerTransitioningDelegate 协议

在页面控制器中实现 `UIViewControllerTransitioningDelegate` 协议，提供自定义的转场动画控制器：

```swift
extension YourViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 返回自定义的进场动画控制器
        return YourCustomPresentAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 返回自定义的退场动画控制器
        return YourCustomDismissAnimator()
    }
}
```
