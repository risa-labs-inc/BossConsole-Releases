# Plugin Context

The `PluginContext` provides plugins with access to host application services during registration and runtime.

## Interface Definition

```kotlin
interface PluginContext {
    /**
     * Registry for panel registration.
     * Plugins use this to register their panel components.
     */
    val panelRegistry: PanelRegistry

    /**
     * Registry for tab type registration.
     * Plugins use this to register custom tab types.
     */
    val tabRegistry: TabRegistry

    /**
     * Coroutine scope tied to the plugin's lifecycle.
     * Use this for long-running operations that should be cancelled when the plugin is disposed.
     */
    val pluginScope: CoroutineScope

    /**
     * Optional reference to the plugin's sandbox for health reporting.
     * Returns null if sandboxing is not enabled.
     */
    val sandbox: PluginSandboxRef?

    /**
     * Optional browser service for plugins that need embedded browser capabilities.
     * Returns null if browser service is not available.
     */
    val browserService: BrowserService?

    /**
     * The plugin's manifest, providing access to configuration declared in plugin.json.
     * Returns null for built-in plugins that don't have a manifest file.
     */
    val manifest: PluginManifest?
}
```

## Available Services

### Panel Registry

Register sidebar panels:

```kotlin
context.panelRegistry.registerPanel(MyPanelInfo) { ctx, info ->
    MyPanelComponent(ctx, info)
}
```

### Tab Registry

Register custom tab types:

```kotlin
context.tabRegistry.registerTabType(MyTabType) { tabInfo, ctx ->
    MyTabComponent(tabInfo, ctx)
}
```

### Plugin Scope

Launch coroutines that are automatically cancelled when the plugin is disposed:

```kotlin
context.pluginScope.launch {
    // Long-running work
    while (isActive) {
        doPeriodicWork()
        delay(1000)
    }
}
```

### Browser Service

Create embedded browser instances (may be null):

```kotlin
context.browserService?.let { service ->
    if (service.isAvailable()) {
        val browser = service.createBrowser(BrowserConfig(url = "https://example.com"))
        // Use browser...
    }
}
```

### Sandbox Reference

Report health status (may be null):

```kotlin
context.sandbox?.let { sandbox ->
    sandbox.recordHeartbeat()  // I'm alive!
    sandbox.recordSuccess()    // Operation succeeded
    sandbox.recordError(e)     // Something went wrong
}
```

### Plugin Manifest

Access configuration from plugin.json:

```kotlin
context.manifest?.let { manifest ->
    val version = manifest.version
    val config = manifest.panel
}
```

## Sandbox Reference API

```kotlin
interface PluginSandboxRef {
    val pluginId: String
    fun recordHeartbeat()
    fun recordSuccess()
    fun recordError(error: Throwable)
}
```

## Related

- [Plugin Interface](Plugin-Interface.md) - Main plugin interface
- [Panel API](Panel-API.md) - Panel registration
- [Tab API](Tab-API.md) - Tab registration
- [Browser Service API](Browser-Service-API.md) - Browser service
