
_G.sys = require("sys")
require "sysplus"
--[[
PC接at6558r-BD
]]

local at6558r = require("at6558r")

local gps_uart_id = 35

sys.taskInit(function()
    at6558r.setup({
        uart_id = gps_uart_id, -- GNSS芯片所接的UART ID, 默认是2
        debug = true,          -- 是否开启调试信息, 默认是false
        sys = 7,               -- 指定定位系统, 1:GPS, 2:BDS, 4:GLO, 可任意相加, 默认是 3:GPS+BDS, 单北斗填2
        -- rmc_only = true,    -- 仅输出RMC信息,调试用
        -- nmea_ver = 40,      -- 设置NMEA协议版本,默认4.1
        -- no_nmea = true,     -- 关闭NMEA输出,调试用
    })
    at6558r.start()
    at6558r.agps()
end)

sys.taskInit(function()
    while 1 do
        sys.wait(600 * 1000)
        if not libgnss.isFix() then
            at6558r.agps()
        else
            at6558r.saveloc()
        end
    end
end)

local function reboot_wait(mode, tag, timeout)
    at6558r.reboot(mode)
    local tnow = os.time()
    sys.waitUntil("GNSS_STATE", 3000)
    sys.waitUntil("GNSS_STATE", timeout)
    if libgnss.isFix() then
        log.info("at6558r", tag .. "耗时",  os.time() - tnow)
    else
        log.info("at6558r", tag .. "后定位超时")
    end
end

sys.taskInit(function()
    local tnow
    local result
    sys.waitUntil("GNSS_STATE")
    while true do
        sys.wait(3000)
        -- log.info("at6558r", "测试热重启一次,并等待30秒")
        -- reboot_wait(0, "热重启", 30000)
        -- log.info("at6558r", "测试温重启一次,并等待60秒")
        -- reboot_wait(1, "温重启", 60000)
        -- log.info("at6558r", "测试冷重启一次,并等待600秒")
        -- reboot_wait(2, "冷重启", 600000)

        -- 测试彻底清空数据, 恢复出厂状态
        -- log.info("at6558r", "测试出厂重启一次,并等待240秒")
        -- at6558r.reboot(3)
        -- sys.wait(100)
        -- at6558r.stop()
        -- sys.wait(1000)
        -- at6558r.start()
        -- libgnss.clear()
        -- -- sys.wait(1000)
        -- at6558r.agps(true)
        -- sys.waitUntil("GNSS_STATE", 600000)
        sys.wait(60000)
    end
end)

sys.taskInit(function()
    while 1 do
        sys.wait(2000)
        -- log.info("RMC", json.encode(libgnss.getRmc(2) or {}, "7f"))
        -- log.info("RMC", (libgnss.getRmc(2) or {}).valid, os.date())
        -- log.info("INT", libgnss.getIntLocation())
        -- log.info("GGA", libgnss.getGga(3))
        -- log.info("GLL", json.encode(libgnss.getGll(2) or {}, "7f"))
        -- log.info("GSA", json.encode(libgnss.getGsa(1) or {}, "3f"))
        -- log.info("GSA", #libgnss.getGsa(0).sats)
        -- log.info("GSV", json.encode(libgnss.getGsv(2) or {}, "7f"))
        -- log.info("VTG", json.encode(libgnss.getVtg(2) or {}, "7f"))
        -- log.info("ZDA", json.encode(libgnss.getZda(2) or {}, "7f"))
        -- log.info("date", os.date())
        -- log.info("sys", rtos.meminfo("sys"))
        -- log.info("lua", rtos.meminfo("lua"))

        -- 打印全部卫星
        -- local gsv = libgnss.getGsv() or {sats={}}
        -- for i, v in ipairs(gsv.sats) do
        --     log.info("sat", i, v.nr, v.snr, v.azimuth, v.elevation)
        -- end
    end
end)

sys.run()
