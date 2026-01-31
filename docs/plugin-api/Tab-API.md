# Tab API

Tabs are the main content area in BOSS. Plugins can register custom tab types for specialized content views.

## Key Interfaces

### TabTypeId

Unique identifier for a tab type:

```kotlin
data class TabTypeId(
    val typeId: String,
    val pluginId: String = "ai.rever.boss"
)
```

### TabTypeInfo

Describes a tab type:

```kotlin
interface TabTypeInfo {
    val typeId: TabTypeId
    val displayName: String
    val icon: ImageVector
}
```

### TabInfo

Instance of a tab:

```kotlin
interface TabInfo {
    val id: String
    val typeId: TabTypeId
    val title: String
    val icon: ImageVector
    val tabIcon: TabIcon?
}
```

### TabComponentWithUI

The component that renders tab content:

```kotlin
interface TabComponentWithUI : ComponentContext {
    val tabTypeInfo: TabTypeInfo
    val config: TabInfo

    @Composable
    fun Content()
}
```

## Tab Icons

Tabs can use vector or bitmap icons:

```kotlin
sealed class TabIcon {
    data class Vector(
        val imageVector: ImageVector,
        val tint: Color? = null
    ) : TabIcon()

    data class Image(val painter: Painter) : TabIcon()

    @Composable
    fun asPainter(): Painter
}
```

## Creating a Tab Type

### 1. Define Tab Type Info

```kotlin
object MyTabType : TabTypeInfo {
    override val typeId = TabTypeId(
        typeId = "my-custom-tab",
        pluginId = "com.example.my-plugin"
    )
    override val displayName = "My Tab"
    override val icon = Icons.Default.Web
}
```

### 2. Define Tab Info

```kotlin
data class MyTabInfo(
    override val id: String = UUID.randomUUID().toString(),
    override val title: String = "My Tab",
    val url: String = "https://example.com"
) : TabInfo {
    override val typeId = MyTabType.typeId
    override val icon = Icons.Default.Web
    override val tabIcon: TabIcon? = null
}
```

### 3. Create Tab Component

```kotlin
class MyTabComponent(
    override val config: TabInfo,
    componentContext: ComponentContext,
    private val browserService: BrowserService?
) : TabComponentWithUI, ComponentContext by componentContext {

    override val tabTypeInfo = MyTabType

    private var browserHandle: BrowserHandle? = null

    init {
        // Initialize browser if available
        lifecycle.doOnCreate {
            componentCoroutineScope().launch {
                val info = config as? MyTabInfo ?: return@launch
                browserHandle = browserService?.createBrowser(
                    BrowserConfig(url = info.url)
                )
            }
        }
        lifecycle.doOnDestroy {
            browserHandle?.dispose()
        }
    }

    @Composable
    override fun Content() {
        Box(modifier = Modifier.fillMaxSize()) {
            browserHandle?.Content()
                ?: Text("Browser not available")
        }
    }
}
```

### 4. Register the Tab Type

```kotlin
class MyPlugin : Plugin {
    override val pluginId = "com.example.my-plugin"
    override val displayName = "My Plugin"

    private var browserService: BrowserService? = null

    override fun register(context: PluginContext) {
        browserService = context.browserService

        context.tabRegistry.registerTabType(MyTabType) { tabInfo, ctx ->
            MyTabComponent(tabInfo, ctx, browserService)
        }
    }

    override fun dispose() {
        browserService = null
    }
}
```

## Dynamic Tab Icons

Update tab icons at runtime (e.g., show favicon):

```kotlin
class MyTabComponent(...) : TabComponentWithUI, ... {
    private val _tabIcon = mutableStateOf<TabIcon?>(null)

    override val config: TabInfo = object : TabInfo by originalConfig {
        override val tabIcon: TabIcon? get() = _tabIcon.value
    }

    fun updateFavicon(faviconUrl: String) {
        // Load favicon and update icon
        _tabIcon.value = TabIcon.Image(loadedPainter)
    }
}
```

## Tab Lifecycle

Use Decompose's `ComponentContext` for lifecycle management:

```kotlin
init {
    lifecycle.doOnCreate { /* Setup */ }
    lifecycle.doOnStart { /* Resume */ }
    lifecycle.doOnStop { /* Pause */ }
    lifecycle.doOnDestroy { /* Cleanup */ }
}
```

## Best Practices

1. **Handle browser availability** - `browserService` may be null
2. **Clean up resources** - Dispose browsers and cancel coroutines on destroy
3. **Update tab title** - Keep the title relevant to content
4. **Support dynamic icons** - Show favicons or status indicators

## Related

- [Plugin Interface](Plugin-Interface.md) - Plugin implementation
- [Browser Service API](Browser-Service-API.md) - Creating browser instances
- [Plugin Context](Plugin-Context.md) - Tab registration
