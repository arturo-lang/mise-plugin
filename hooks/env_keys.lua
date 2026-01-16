-- hooks/env_keys.lua
-- Configures environment variables for the installed tool
-- Documentation: https://mise.jdx.dev/tool-plugin-development.html#envkeys-hook

function PLUGIN:EnvKeys(ctx)
    -- Available context:
    -- ctx.path - Main installation path
    -- ctx.runtimeVersion - Full version string
    -- ctx.sdkInfo[PLUGIN.name] - SDK information

    local mainPath = ctx.path
    -- local sdkInfo = ctx.sdkInfo[PLUGIN.name]
    -- local version = sdkInfo.version

    local sep = package.config:sub(1, 1)
    local function join(...)
        return table.concat({ ... }, sep)
    end

    local function home_dir()
        local home = os.getenv("HOME") or os.getenv("USERPROFILE")
        if not home or home == "" then
            error("Unable to determine home directory for ~/.arturo")
        end
        return home
    end

    local arturo_home = join(home_dir(), ".arturo")

    -- Basic configuration (minimum required for most tools)
    -- This adds the bin directory to PATH so the tool can be executed
    return {
        {
            key = "PATH",
            value = join(arturo_home, "bin"),
        },
        {
            key = "PATH",
            value = join(arturo_home, "packages", "bin"),
        },
    }

    -- Example: Tool-specific environment variables
    --[[
    return {
        {
            key = "arturo_HOME",
            value = mainPath,
        },
        {
            key = "PATH",
            value = mainPath .. "/bin",
        },
        -- Multiple PATH entries are automatically merged
        {
            key = "PATH",
            value = mainPath .. "/scripts",
        },
    }
    --]]

    -- Example: Library paths for compiled tools
    --[[
    return {
        {
            key = "PATH",
            value = mainPath .. "/bin",
        },
        {
            key = "LD_LIBRARY_PATH",
            value = mainPath .. "/lib",
        },
        {
            key = "PKG_CONFIG_PATH",
            value = mainPath .. "/lib/pkgconfig",
        },
    }
    --]]

    -- Example: Platform-specific configuration
    --[[
    local env_vars = {
        {
            key = "PATH",
            value = mainPath .. "/bin",
        },
    }

    -- RUNTIME object is provided by mise/vfox
    if RUNTIME.osType == "Darwin" then
        table.insert(env_vars, {
            key = "DYLD_LIBRARY_PATH",
            value = mainPath .. "/lib",
        })
    elseif RUNTIME.osType == "Linux" then
        table.insert(env_vars, {
            key = "LD_LIBRARY_PATH",
            value = mainPath .. "/lib",
        })
    end
    -- Windows doesn't use these library path variables

    return env_vars
    --]]
end
