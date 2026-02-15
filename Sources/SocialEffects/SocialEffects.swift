import Foundation

print("🎬 Social Effects - MLT Video Engine")
print("=====================================")
print("")

// Test MLT library availability
let mltPath = "/Applications/Shotcut.app/Contents/Frameworks/libmlt-7.dylib"
let fileManager = FileManager.default

if fileManager.fileExists(atPath: mltPath) {
    print("✅ MLT library found at: \(mltPath)")
    
    // List available MLT plugins
    let pluginsPath = "/Applications/Shotcut.app/Contents/PlugIns/mlt"
    if let plugins = try? fileManager.contentsOfDirectory(atPath: pluginsPath) {
        print("📦 Found \(plugins.count) MLT plugin modules:")
        for plugin in plugins.prefix(10) {
            print("   - \(plugin)")
        }
    }
} else {
    print("❌ MLT library not found. Is Shotcut installed?")
    exit(1)
}

print("")
print("🚀 Next steps:")
print("   1. Create C bridging header for MLT")
print("   2. Test basic video generation")
print("   3. Enumerate available effects")
print("   4. Build XPC service for Social Marketer integration")
