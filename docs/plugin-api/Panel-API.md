# Panel API

Panels are sidebar components that provide quick access to functionality. Plugins can register panels to appear in the left or right sidebar.

## Key Interfaces

### PanelInfo

Describes a panel's metadata:

```kotlin
interface PanelInfo {
    val id: PanelId
    val displayName: String
    val icon: ImageVector
    val defaultSlotPosition: Panel
}
```

### PanelId

Unique identifier for a panel:

```kotlin
data class PanelId(
    val panelId: String,
    val defaultOrder: Int,
    val pluginId: String = "ai.rever.boss"
)
```

### PanelComponentWithUI

The component that renders the panel:

```kotlin
interface PanelComponentWithUI : ComponentContext, PanelLifecycle {
    val panelInfo: PanelInfo

    @Composable
    fun Content()

    override val resetPanelId: PanelId
        get() = panelInfo.id
}
```

## Panel Positions

Panels are positioned using the `Panel` class:

```kotlin
// Left sidebar positions
Panel.left.top.top      // Top slot, first
Panel.left.top.bottom   // Top slot, last
Panel.left.bottom.top   // Bottom slot, first
Panel.left.bottom.bottom // Bottom slot, last

// Right sidebar positions
Panel.right.top.top
Panel.right.bottom.bottom
```

## Creating a Panel

### 1. Define Panel Info

```kotlin
object MyPanelInfo : PanelInfo {
    override val id = PanelId(
        panelId = "my-plugin-panel",
        defaultOrder = 100,
        pluginId = "com.example.my-plugin"
    )
    override val displayName = "My Panel"
    override val icon = Icons.Default.Settings
    override val defaultSlotPosition = Panel.left.bottom.bottom
}
```

### 2. Create Panel Component

```kotlin
class MyPanelComponent(
    componentContext: ComponentContext,
    override val panelInfo: PanelInfo
) : PanelComponentWithUI, ComponentContext by componentContext {

    @Composable
    override fun Content() {
        Column(
            modifier = Modifier.fillMaxSize().padding(16.dp)
        ) {
            Text("Hello from My Panel!")
            Button(onClick = { /* action */ }) {
                Text("Click Me")
            }
        }
    }
}
```

### 3. Register the Panel

```kotlin
class MyPlugin : Plugin {
    override val pluginId = "com.example.my-plugin"
    override val displayName = "My Plugin"

    override fun register(context: PluginContext) {
        context.panelRegistry.registerPanel(MyPanelInfo) { ctx, info ->
            MyPanelComponent(ctx, info)
        }
    }
}
```

## Panel Lifecycle

Panels implement `PanelLifecycle` for lifecycle hooks:

```kotlin
interface PanelLifecycle {
    val resetPanelId: PanelId

    /** Called when the panel becomes visible */
    fun onPanelShown() {}

    /** Called when the panel becomes hidden */
    fun onPanelHidden() {}

    /** Called to reset panel state */
    fun onPanelReset() {}
}
```

## Manifest Configuration

You can configure panel appearance in `plugin.json`:

```json
{
    "panel": {
        "icon": "Settings",
        "location": "left.bottom.bottom",
        "order": 100,
        "panelId": "custom-panel-id",
        "displayName": "Custom Name"
    }
}
```

## Available Icons

Use any icon from Material Icons Outlined. Common examples:
- `Settings`, `Home`, `Search`, `Info`
- `Chat`, `Code`, `Terminal`, `Folder`
- `Download`, `Upload`, `Bookmark`, `Star`

## Best Practices

1. **Keep panels lightweight** - Panels should load quickly
2. **Handle visibility** - Use lifecycle hooks to pause expensive operations when hidden
3. **Respect theming** - Use Material theme colors
4. **Provide tooltips** - Help users understand panel functionality

## Related

- [Plugin Interface](Plugin-Interface.md) - Plugin implementation
- [Plugin Manifest](Plugin-Manifest.md) - Manifest configuration
- [Plugin Context](Plugin-Context.md) - Panel registration
