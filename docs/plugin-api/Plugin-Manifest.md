# Plugin Manifest

The plugin manifest (`plugin.json`) declares your plugin's metadata, capabilities, and configuration. It must be placed at `META-INF/boss-plugin/plugin.json` in your plugin JAR.

## Full Schema

```kotlin
@Serializable
data class PluginManifest(
    val manifestVersion: Int = 1,           // Always 1
    val pluginId: String,                   // Unique ID (required)
    val displayName: String,                // Human-readable name (required)
    val version: String,                    // Semantic version (required)
    val apiVersion: String,                 // Minimum API version (required)
    val mainClass: String,                  // Plugin class name (required)
    val type: PluginType = PANEL,           // Plugin type
    val description: String = "",           // Optional description
    val author: String = "",                // Optional author
    val url: String = "",                   // Optional homepage
    val dependencies: List<PluginDependency> = emptyList(),
    val sandbox: PluginSandboxConfig = PluginSandboxConfig(),
    val sharedPackages: List<String> = emptyList(),
    val isDynamic: Boolean = true,          // Supports runtime loading
    val unloadActions: PluginUnloadActions = PluginUnloadActions(),
    val panel: PluginPanelConfig? = null    // Panel-specific config
)
```

## Plugin Types

```kotlin
enum class PluginType {
    PANEL,    // Provides a sidebar panel
    TAB,      // Provides a tab type
    MIXED,    // Provides both panels and tabs
    SERVICE   // Background service (no UI)
}
```

## Example Manifests

### Simple Panel Plugin

```json
{
    "manifestVersion": 1,
    "pluginId": "com.example.my-panel",
    "displayName": "My Panel",
    "version": "1.0.0",
    "apiVersion": "1.0",
    "mainClass": "com.example.MyPanelPlugin",
    "type": "panel",
    "description": "A simple panel plugin",
    "panel": {
        "icon": "Settings",
        "location": "left.bottom.bottom"
    }
}
```

### Browser Tab Plugin

```json
{
    "manifestVersion": 1,
    "pluginId": "com.example.browser-tab",
    "displayName": "Browser Tab",
    "version": "1.0.0",
    "apiVersion": "1.0",
    "mainClass": "com.example.BrowserTabPlugin",
    "type": "tab",
    "description": "Custom browser tab",
    "sharedPackages": [
        "ai.rever.boss.plugin.browser."
    ],
    "sandbox": {
        "enableSandbox": true,
        "maxRestartAttempts": 3
    }
}
```

### Mixed Plugin with Dependencies

```json
{
    "manifestVersion": 1,
    "pluginId": "com.example.advanced",
    "displayName": "Advanced Plugin",
    "version": "2.0.0",
    "apiVersion": "1.0",
    "mainClass": "com.example.AdvancedPlugin",
    "type": "mixed",
    "author": "Example Corp",
    "url": "https://example.com/plugin",
    "dependencies": [
        {
            "pluginId": "com.example.base-plugin",
            "version": ">=1.0.0"
        }
    ],
    "sandbox": {
        "maxThreads": 4,
        "heartbeatIntervalMs": 10000
    }
}
```

## Sandbox Configuration

```kotlin
data class PluginSandboxConfig(
    val maxThreads: Int = 2,                    // Max concurrent threads
    val maxMemoryMb: Int = 0,                   // Memory limit (0 = unlimited)
    val enableSandbox: Boolean = true,          // Enable crash isolation
    val heartbeatIntervalMs: Long = 5000,       // Health check interval
    val maxRestartAttempts: Int = 3             // Restart limit before disabling
)
```

## Panel Configuration

```kotlin
data class PluginPanelConfig(
    val icon: String = "Extension",             // Material icon name
    val location: String = "left.bottom.bottom", // Panel location
    val order: Int = 100,                       // Sort order
    val panelId: String? = null,                // Custom panel ID
    val displayName: String? = null             // Override display name
)
```

### Panel Locations

Format: `side.slot.position`

| Side | Slots | Positions |
|------|-------|-----------|
| `left` | `top`, `bottom` | `top`, `middle`, `bottom` |
| `right` | `top`, `bottom` | `top`, `middle`, `bottom` |

Examples:
- `left.top.top` - Left sidebar, top slot, first position
- `right.bottom.middle` - Right sidebar, bottom slot, middle position

## Dependency Configuration

```kotlin
data class PluginDependency(
    val pluginId: String,          // Required plugin ID
    val version: String = "*",     // Version constraint
    val optional: Boolean = false  // Optional dependency
)
```

Version constraints:
- `*` - Any version
- `1.0.0` - Exact version
- `>=1.0.0` - Minimum version
- `>=1.0.0 <2.0.0` - Version range

## Related

- [Plugin Interface](Plugin-Interface.md) - Implementing the Plugin class
- [Panel API](Panel-API.md) - Panel implementation details
