# Browser Service API

The Browser Service API allows plugins to create embedded browser instances using the host application's JxBrowser infrastructure.

## Availability

The browser service may not be available if:
- JxBrowser license is not configured
- Browser engine failed to initialize
- Platform doesn't support embedded browsers

Always check `browserService` is not null and `isAvailable()` returns true.

## Key Interfaces

### BrowserService

```kotlin
interface BrowserService {
    /**
     * Check if browsers can be created.
     */
    fun isAvailable(): Boolean

    /**
     * Create a new browser instance.
     */
    suspend fun createBrowser(config: BrowserConfig): BrowserHandle?

    /**
     * Dispose a browser instance.
     */
    suspend fun disposeBrowser(handle: BrowserHandle)

    /**
     * Get the current number of active browsers.
     */
    fun getActiveBrowserCount(): Int
}
```

### BrowserConfig

```kotlin
data class BrowserConfig(
    val url: String = "",                 // Initial URL
    val enableDevTools: Boolean = false,  // Enable F12 dev tools
    val enableDownloads: Boolean = true,  // Allow file downloads
    val enableFullscreen: Boolean = true, // Allow fullscreen video
    val userAgent: String? = null         // Custom user agent
)
```

### BrowserHandle

```kotlin
interface BrowserHandle {
    val id: String
    val isValid: Boolean

    // Navigation
    suspend fun loadUrl(url: String)
    fun getCurrentUrl(): String
    fun getTitle(): String
    fun goBack()
    fun goForward()
    fun reload()
    fun canGoBack(): Boolean
    fun canGoForward(): Boolean

    // Event listeners
    fun addNavigationListener(listener: (String) -> Unit)
    fun removeNavigationListener(listener: (String) -> Unit)
    fun addTitleListener(listener: (String) -> Unit)
    fun removeTitleListener(listener: (String) -> Unit)
    fun addFaviconListener(listener: (String?) -> Unit)
    fun removeFaviconListener(listener: (String?) -> Unit)

    // Rendering
    @Composable
    fun Content()

    // Cleanup
    fun dispose()
}
```

## Usage Example

### Basic Browser Tab

```kotlin
class BrowserTabPlugin : Plugin {
    override val pluginId = "com.example.browser-tab"
    override val displayName = "Browser Tab"

    private var browserService: BrowserService? = null

    override fun register(context: PluginContext) {
        browserService = context.browserService

        // Check availability
        if (browserService?.isAvailable() != true) {
            println("Browser service not available")
            return
        }

        context.tabRegistry.registerTabType(BrowserTabType) { tabInfo, ctx ->
            BrowserTabComponent(tabInfo, ctx, browserService!!)
        }
    }

    override fun dispose() {
        browserService = null
    }
}
```

### Browser Component

```kotlin
class BrowserTabComponent(
    override val config: TabInfo,
    componentContext: ComponentContext,
    private val browserService: BrowserService
) : TabComponentWithUI, ComponentContext by componentContext {

    override val tabTypeInfo = BrowserTabType

    private var browserHandle: BrowserHandle? = null
    private var currentUrl by mutableStateOf("")
    private var currentTitle by mutableStateOf("Loading...")

    init {
        lifecycle.doOnCreate {
            componentCoroutineScope().launch {
                val info = config as? BrowserTabInfo ?: return@launch
                browserHandle = browserService.createBrowser(
                    BrowserConfig(
                        url = info.url,
                        enableDevTools = true
                    )
                )

                browserHandle?.apply {
                    addNavigationListener { url -> currentUrl = url }
                    addTitleListener { title -> currentTitle = title }
                }
            }
        }

        lifecycle.doOnDestroy {
            browserHandle?.dispose()
            browserHandle = null
        }
    }

    @Composable
    override fun Content() {
        Column(modifier = Modifier.fillMaxSize()) {
            // Navigation bar
            Row(
                modifier = Modifier.fillMaxWidth().height(40.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(
                    onClick = { browserHandle?.goBack() },
                    enabled = browserHandle?.canGoBack() == true
                ) {
                    Icon(Icons.Default.ArrowBack, "Back")
                }
                IconButton(
                    onClick = { browserHandle?.goForward() },
                    enabled = browserHandle?.canGoForward() == true
                ) {
                    Icon(Icons.Default.ArrowForward, "Forward")
                }
                IconButton(onClick = { browserHandle?.reload() }) {
                    Icon(Icons.Default.Refresh, "Reload")
                }
                Text(
                    text = currentUrl,
                    modifier = Modifier.weight(1f).padding(horizontal = 8.dp),
                    maxLines = 1
                )
            }

            // Browser content
            Box(modifier = Modifier.fillMaxSize()) {
                browserHandle?.Content()
                    ?: CircularProgressIndicator(Modifier.align(Alignment.Center))
            }
        }
    }
}
```

## Event Handling

### Navigation Events

```kotlin
browserHandle?.addNavigationListener { newUrl ->
    println("Navigated to: $newUrl")
    // Update UI, save history, etc.
}
```

### Title Changes

```kotlin
browserHandle?.addTitleListener { newTitle ->
    // Update tab title
    tabTitle = newTitle
}
```

### Favicon Changes

```kotlin
browserHandle?.addFaviconListener { faviconUrl ->
    // Load and display favicon
    if (faviconUrl != null) {
        loadFavicon(faviconUrl)
    }
}
```

## Best Practices

1. **Always check availability** - Browser service may be null or unavailable
2. **Dispose browsers** - Call `dispose()` to free resources
3. **Remove listeners** - Remove event listeners before disposal
4. **Handle errors** - `createBrowser()` may return null on failure
5. **Thread safety** - All methods except `Content()` are thread-safe

## Shared Packages

Add to your manifest to ensure proper classloading:

```json
{
    "sharedPackages": [
        "ai.rever.boss.plugin.browser."
    ]
}
```

## Resource Monitoring

Track browser count for debugging:

```kotlin
val count = browserService?.getActiveBrowserCount() ?: 0
println("Active browsers: $count")
```

## Related

- [Plugin Context](Plugin-Context.md) - Accessing browser service
- [Tab API](Tab-API.md) - Creating browser tabs
- [Plugin Manifest](Plugin-Manifest.md) - Shared packages configuration
