-- Performs additional setup after installation
-- Documentation: https://mise.jdx.dev/tool-plugin-development.html#postinstall-hook

function PLUGIN:PostInstall(ctx)
    local sdkInfo = ctx.sdkInfo[PLUGIN.name]
    local path = sdkInfo.path
    local sep = package.config:sub(1, 1)
    local runtime_os = RUNTIME and RUNTIME.osType and RUNTIME.osType:lower() or ""
    local is_windows = runtime_os == "windows" or sep == "\\" or os.getenv("OS") == "Windows_NT"

    local function join(...)
        return table.concat({ ... }, sep)
    end

    local function ensure_dir(dir)
        local cmd
        if is_windows then
            cmd = string.format('cmd /C if not exist "%s" mkdir "%s" 1> nul 2> nul', dir, dir)
        else
            cmd = string.format('mkdir -p "%s"', dir)
        end

        local res = os.execute(cmd)
        if res ~= 0 then
            error("Failed to create directory: " .. dir)
        end
    end

    local function home_dir()
        local home = os.getenv("HOME") or os.getenv("USERPROFILE")
        if not home or home == "" then
            error("Unable to determine home directory for ~/.arturo")
        end
        return home
    end

    local arturo_home = join(home_dir(), ".arturo")
    local arturo_bin = join(arturo_home, "bin")
    ensure_dir(arturo_home)
    ensure_dir(arturo_bin)

    local install_bin = path
    ensure_dir(install_bin)

    local function move_binaries()
        if is_windows then
            local move_cmd = string.format(
                'for /d %%D in ("%s") do if exist "%%~fD\\bin" move /Y "%%~fD\\bin\\*" "%s" >nul',
                join(path, "arturo-*")
                    ,
                install_bin
            )
            local res = os.execute(move_cmd)
            if res ~= 0 then
                error("Failed to move arturo binaries into " .. install_bin)
            end
        else
            local src_glob = join(path, "arturo-*", "bin", "*")
            local res = os.execute(string.format('mv %s "%s"', src_glob, install_bin))
            if res ~= 0 then
                error("Failed to move arturo binaries into " .. install_bin)
            end
            os.execute(string.format('chmod +x "%s"/*', install_bin))
        end
    end

    move_binaries()

    if install_bin ~= arturo_bin then
        local copy_cmd
        if is_windows then
            copy_cmd = string.format('copy /Y "%s\\*" "%s" >nul', install_bin, arturo_bin)
        else
            copy_cmd = string.format('cp -f %s/* "%s"', install_bin, arturo_bin)
        end
        os.execute(copy_cmd)
    end

end
