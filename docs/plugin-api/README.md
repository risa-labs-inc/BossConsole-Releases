# BOSS Plugin API Documentation

Welcome to the official documentation for the BOSS Plugin API. This repository hosts the Maven packages for building external plugins for the BOSS desktop application.

## Published Packages

| Package | Description |
|---------|-------------|
| `ai.rever.boss.api:plugin-api` | Core plugin API with interfaces for panels, tabs, and plugin lifecycle |
| `ai.rever.boss.api:plugin-api-browser` | Browser service API for plugins needing embedded browser capabilities |
| `ai.rever.boss.api:plugin-workspace-types` | Workspace data types and interfaces |
| `ai.rever.boss.api:plugin-bookmark-types` | Bookmark data types and interfaces |

## Quick Start

### 1. Add Repository

Add the GitHub Packages repository to your `build.gradle.kts`:

```kotlin
repositories {
    mavenCentral()
    google()
    maven("https://maven.pkg.jetbrains.space/public/p/compose/dev")

    // BOSS Plugin API packages
    maven {
        url = uri("https://maven.pkg.github.com/risa-labs-inc/BossConsole-Releases")
        credentials {
            username = System.getenv("GITHUB_ACTOR") ?: project.findProperty("gpr.user") as String? ?: ""
            password = System.getenv("GITHUB_TOKEN") ?: project.findProperty("gpr.token") as String? ?: ""
        }
    }
}
```

### 2. Add Dependencies

```kotlin
dependencies {
    // Core Plugin API (required)
    compileOnly("ai.rever.boss.api:plugin-api-desktop:1.0.0")

    // Browser API (optional - for plugins with embedded browsers)
    compileOnly("ai.rever.boss.api:plugin-api-browser-desktop:1.0.0")

    // Compose (shared from host)
    compileOnly(compose.runtime)
    compileOnly(compose.ui)
    compileOnly(compose.foundation)
    compileOnly(compose.material)
}
```

### 3. Create Plugin Class

```kotlin
class MyPlugin : Plugin {
    override val pluginId = "com.example.my-plugin"
    override val displayName = "My Plugin"

    override fun register(context: PluginContext) {
        // Register panels, tabs, etc.
    }

    override fun dispose() {
        // Clean up resources
    }
}
```

### 4. Create Plugin Manifest

Create `META-INF/boss-plugin/plugin.json`:

```json
{
    "manifestVersion": 1,
    "pluginId": "com.example.my-plugin",
    "displayName": "My Plugin",
    "version": "1.0.0",
    "apiVersion": "1.0",
    "mainClass": "com.example.MyPlugin",
    "type": "panel"
}
```

## Documentation

- [Plugin Interface](Plugin-Interface.md) - Core Plugin interface and lifecycle
- [Plugin Context](Plugin-Context.md) - Context provided to plugins
- [Plugin Manifest](Plugin-Manifest.md) - Plugin configuration and metadata
- [Panel API](Panel-API.md) - Creating sidebar panels
- [Tab API](Tab-API.md) - Creating custom tab types
- [Browser Service API](Browser-Service-API.md) - Embedded browser capabilities

## Authentication

GitHub Packages requires authentication. Set these environment variables:
- `GITHUB_ACTOR`: Your GitHub username
- `GITHUB_TOKEN`: A Personal Access Token with `read:packages` scope

Or add to `~/.gradle/gradle.properties`:
```properties
gpr.user=your-github-username
gpr.token=ghp_your_token_here
```

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-31 | Initial public release |

## License

These packages are provided for use with the BOSS desktop application. See the [BOSS license](https://github.com/risa-labs-inc/BossConsole) for details.
