# Plugin Interface

The `Plugin` interface is the entry point for all BOSS plugins. Every plugin must implement this interface.

## Interface Definition

```kotlin
interface Plugin {
    /**
     * Unique identifier for this plugin.
     * Should follow reverse domain notation (e.g., "com.example.my-plugin")
     */
    val pluginId: String

    /**
     * Human-readable name for this plugin.
     */
    val displayName: String

    /**
     * Register this plugin's panels and tab types with the host application.
     *
     * @param context The plugin context providing access to registries
     */
    fun register(context: PluginContext)

    /**
     * Called when the plugin is being disposed.
     * Override to clean up any resources.
     */
    fun dispose() {}
}
```

## Lifecycle

1. **Loading**: The plugin JAR is loaded by the host application
2. **Instantiation**: The main class (specified in manifest) is instantiated
3. **Registration**: `register(context)` is called - register your panels and tabs here
4. **Running**: Plugin is active and responding to user interactions
5. **Disposal**: `dispose()` is called - clean up resources here
6. **Unloading**: The plugin is unloaded from memory

## Example Implementation

```kotlin
class MyPlugin : Plugin {
    override val pluginId = "com.example.my-plugin"
    override val displayName = "My Awesome Plugin"

    private var browserService: BrowserService? = null

    override fun register(context: PluginContext) {
        // Store service references
        browserService = context.browserService

        // Register a panel
        context.panelRegistry.registerPanel(MyPanelInfo) { ctx, info ->
            MyPanelComponent(ctx, info)
        }

        // Register a tab type
        context.tabRegistry.registerTabType(MyTabType) { tabInfo, ctx ->
            MyTabComponent(tabInfo, ctx)
        }
    }

    override fun dispose() {
        // Clean up resources
        browserService = null
    }
}
```

## Best Practices

1. **Store context references**: Save services from `PluginContext` during registration
2. **Dispose resources**: Always clean up in `dispose()` to prevent memory leaks
3. **Use plugin scope**: Use `context.pluginScope` for coroutines that should be cancelled on disposal
4. **Handle null services**: Browser service may be null if not available

## Related

- [Plugin Context](Plugin-Context.md) - Services available during registration
- [Plugin Manifest](Plugin-Manifest.md) - Configuration in plugin.json
