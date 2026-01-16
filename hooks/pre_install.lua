-- hooks/pre_install.lua
-- Returns download information for a specific version
-- Documentation: https://mise.jdx.dev/tool-plugin-development.html#preinstall-hook

function PLUGIN:PreInstall(ctx)
    local version = ctx.version
    -- ctx.runtimeVersion contains the full version string if needed

    -- Example 1: Simple binary download
    -- local url = "https://github.com/arturo-lang/arturo/releases/download/v" .. version .. "/arturo-linux-amd64"

    -- Example 2: Platform-specific binary
    local platform = get_platform() -- Uncomment the helper function above
    local url = "https://github.com/arturo-lang/arturo/releases/download/v" .. version .. "/arturo-" .. version .. "-" .. platform .. ".zip"

    -- Example 3: Archive (tar.gz, zip) - mise will extract automatically
    -- local url = "https://github.com/arturo-lang/arturo/releases/download/v" .. version .. "/arturo-" .. version .. "-linux-amd64.tar.gz"

    -- Example 4: Raw file from repository
    -- local url = "https://raw.githubusercontent.com/arturo-lang/arturo/" .. version .. "/bin/arturo"

    -- Replace with your actual download URL pattern
    -- local url = "https://example.com/arturo/releases/download/" .. version .. "/arturo"

    -- Optional: Fetch checksum for verification
    -- local sha256 = fetch_checksum(version) -- Implement if checksums are available

    return {
        version = version,
        url = url,
        -- sha256 = sha256, -- Optional but recommended for security
        note = "Downloading arturo " .. version,
        -- addition = { -- Optional: download additional components
        --     {
        --         name = "component",
        --         url = "https://example.com/component.tar.gz"
        --     }
        -- }
    }
end

-- Helper function for platform detection (uncomment and modify as needed)
local function get_platform()
    -- RUNTIME object is provided by mise/vfox
    -- RUNTIME.osType: "Windows", "Linux", "Darwin"
    -- RUNTIME.archType: "amd64", "386", "arm64", etc.

    local os_name = RUNTIME.osType:lower()
    local arch = RUNTIME.archType

    -- Map to your tool's platform naming convention
    -- Adjust these mappings based on how your tool names its releases
    local platform_map = {
        ["darwin"] = {
            ["amd64"] = "macos-amd64",
            ["arm64"] = "macos-arm64",
        },
        ["linux"] = {
            ["amd64"] = "linux-amd64",
            ["arm64"] = "linux-arm64",
        },
        ["windows"] = {
            ["amd64"] = "windows-amd64",
        }
    }

    local os_map = platform_map[os_name]
    if os_map then
        return os_map[arch] or "linux-amd64"  -- fallback
    end

    -- Default fallback
    return "linux-amd64"
end
