-- various audio visualization

local opts = {
    mode = "novideo",
    -- off              disable visualization
    -- noalbumart       enable visualization when no albumart and no video
    -- novideo          enable visualization when no video
    -- force            always enable visualization

    name = "showcqtbar",
    -- off
    -- showcqt
    -- avectorscope
    -- showspectrum
    -- showcqtbar
    -- showwaves

    quality = "high",
    -- verylow
    -- low
    -- medium
    -- high
    -- veryhigh

    height = 6,
    -- [4 .. 12]
}

local force_opt = {
    force = false,
}

-- key bindings
-- cycle visualizer
local cycle_key = "c"

if not (mp.get_property("options/lavfi-complex", "") == "") then
    return
end

local visualizer_name_list = {
    "off",
    "showcqt",
    "avectorscope",
    "showspectrum",
    "showcqtbar",
    "showwaves",
}

local options = require 'mp.options'
local msg     = require 'mp.msg'

options.read_options(opts)
opts.height = math.min(12, math.max(4, opts.height))
opts.height = math.floor(opts.height)

read_options(force_opt, "vis")
print("Force:", type(force_opt.force))
if force_opt.force == true then
    print("vis: forcing visualization")
    opts.mode = "force"
end

local function get_visualizer(name, quality)
    local w, h, fps

    if quality == "verylow" then
        w = 640
        fps = 30
    elseif quality == "low" then
        w = 960
        fps = 30
    elseif quality == "medium" then
        w = 1280
        fps = 60
    elseif quality == "high" then
        w = 1920
        fps = 60
    elseif quality == "veryhigh" then
        w = 2560
        fps = 60
    else
        msg.log("error", "invalid quality")
        return ""
    end

    h = w * opts.height / 16

    if name == "showcqt" then
        local count = math.ceil(w * 180 / 1920 / fps)

        return "[aid1] asplit [ao]," ..
            "afifo, aformat     = channel_layouts = stereo," ..
            "firequalizer       =" ..
                "gain           = '1.4884e8 * f*f*f / (f*f + 424.36) / (f*f + 1.4884e8) / sqrt(f*f + 25122.25)':" ..
                "scale          = linlin:" ..
                "wfunc          = tukey:" ..
                "zero_phase     = on:" ..
                "fft2           = on," ..
            "showcqt            =" ..
                "fps            =" .. fps .. ":" ..
                "size           =" .. w .. "x" .. h .. ":" ..
                "count          =" .. count .. ":" ..
                "csp            = bt709:" ..
                "bar_g          = 2:" ..
                "sono_g         = 4:" ..
                "bar_v          = 9:" ..
                "sono_v         = 17:" ..
                "axis           = 0:" ..
                -- "axisfile       = data\\\\:'" .. axis_0 .. "':" ..
                -- "font           = 'Nimbus Mono L,Courier New,mono|bold':" ..
                -- "fontcolor      = 'st(0, (midi(f)-53.5)/12); st(1, 0.5 - 0.5 * cos(PI*ld(0))); r(1-ld(1)) + b(ld(1))':" ..
                "tc             = 0.33:" ..
                "attack         = 0.033:" ..
                "tlength        = 'st(0,0.17); 384*tc / (384 / ld(0) + tc*f /(1-ld(0))) + 384*tc / (tc*f / ld(0) + 384 /(1-ld(0)))'," ..
            "format             = yuv420p [vo]"


    elseif name == "avectorscope" then
        return "[aid1] asplit [ao]," ..
            "afifo," ..
            "aformat            =" ..
                "sample_rates   = 192000," ..
            "avectorscope       =" ..
                "size           =" .. w .. "x" .. h .. ":" ..
                "r              =" .. fps .. "," ..
            "format             = rgb0 [vo]"


    elseif name == "showspectrum" then
        return "[aid1] asplit [ao]," ..
            "afifo," ..
            "showspectrum       =" ..
                "size           =" .. w .. "x" .. h .. ":" ..
                "win_func       = blackman [vo]"


    elseif name == "showcqtbar" then
        local axis_h = math.ceil(w * 12 / 1920) * 4
        local vh = 1080/2

        return "[aid1] asplit [aa][ao]," ..
            "[aa] channelsplit [ao1][ao2]," ..
            -- "[aid1] channelsplit [ao4],"..
            -- "filter_complex      ="..
            --  "pan            =stereo|c0=c0,c1=c0,"..
            "[ao1] afifo, aformat     = channel_layouts = FL," ..
            "firequalizer       =" ..
                "gain           = '1.4884e8 * f*f*f / (f*f + 424.36) / (f*f + 1.4884e8) / sqrt(f*f + 25122.25)':" ..
                "scale          = linlin:" ..
                "wfunc          = tukey:" ..
                "zero_phase     = on:" ..
                "fft2           = on," ..
            "showcqt            =" ..
                "fps            =" .. fps .. ":" ..
                "size           =" .. w .. "x" .. vh .. ":" ..
                "count          = 1:" ..
                "csp            = fcc:" ..
                "bar_g          = 2:" ..
                "sono_g         = 4:" ..
                "bar_v          = 9:" ..
                "sono_v         = 1000:" ..
                "sono_h         = 0:" ..
                "bar_t          = 0.1:" ..
                "axis           = 0:" ..
                "tc             = 0.33:" ..
                "attack         = 0.143:" ..
                "tlength        = 'st(0,0.17); 384*tc / (384 / ld(0) + tc*f /(1-ld(0))) + 384*tc / (tc*f / ld(0) + 384 /(1-ld(0)))'," ..
            "format             = yuv420p [v0]," ..

            "[ao2] afifo, aformat     = channel_layouts = FR," ..
            "firequalizer       =" ..
                "gain           = '1.4884e8 * f*f*f / (f*f + 424.36) / (f*f + 1.4884e8) / sqrt(f*f + 25122.25)':" ..
                "scale          = linlin:" ..
                "wfunc          = tukey:" ..
                "zero_phase     = on:" ..
                "fft2           = on," ..
            "showcqt            =" ..
                "fps            =" .. fps .. ":" ..
                "size           =" .. w .. "x" .. vh .. ":" ..
                "count          = 1:" ..
                "csp            = fcc:" ..
                "bar_g          = 2:" ..
                "sono_g         = 4:" ..
                "bar_v          = 9:" ..
                "sono_v         = 1000:" ..
                "sono_h         = 0:" ..
                "bar_t          = 0.1:" ..
                "axis           = 0:" ..
                "tc             = 0.33:" ..
                "attack         = 0.143:" ..
                "tlength        = 'st(0,0.17); 384*tc / (384 / ld(0) + tc*f /(1-ld(0))) + 384*tc / (tc*f / ld(0) + 384 /(1-ld(0)))'," ..
            "format             = yuv420p [v1];" ..
            "[v1] vflip [v2]," ..
            "[v0][v2] vstack [vo]"


    elseif name == "showwaves" then
        return "[aid1] asplit [ao]," ..
            "afifo," ..
            "showwaves          =" ..
                "size           =" .. w .. "x" .. h .. ":" ..
                "r              =" .. fps .. ":" ..
                "mode           = p2p," ..
            "format             = rgb0 [vo]"
    elseif name == "off" then
        return "[aid1] afifo [ao]; [vid1] fifo [vo]"
    end

    msg.log("error", "invalid visualizer name")
    return ""
end

local function select_visualizer(atrack, vtrack, albumart)
    if opts.mode == "off" then
        return ""
    elseif opts.mode == "force" then
        return get_visualizer(opts.name, opts.quality)
    elseif opts.mode == "noalbumart" then
        if albumart == 0 and vtrack == 0 then
            return get_visualizer(opts.name, opts.quality)
        end
        return ""
    elseif opts.mode == "novideo" then
        if vtrack == 0 then
            return get_visualizer(opts.name, opts.quality)
        end
        return ""
    end

    msg.log("error", "invalid mode")
    return ""
end

local function visualizer_hook()
    local count = mp.get_property_number("track-list/count", -1)
    local atrack = 0
    local vtrack = 0
    local albumart = 0
    if count <= 0 then
        return
    end
    for tr = 0,count-1 do
        if mp.get_property("track-list/" .. tr .. "/type") == "audio" then
            atrack = atrack + 1
        else
            if mp.get_property("track-list/" .. tr .. "/type") == "video" then
                if mp.get_property("track-list/" .. tr .. "/albumart") == "yes" then
                    albumart = albumart + 1
                else
                    vtrack = vtrack + 1
                end
            end
        end
    end

    mp.set_property("options/lavfi-complex", select_visualizer(atrack, vtrack, albumart))
end

mp.add_hook("on_preloaded", 50, visualizer_hook)

local function cycle_visualizer()
    local i, index = 1
    for i = 1, #visualizer_name_list do
        if (visualizer_name_list[i] == opts.name) then
            index = i + 1
            if index > #visualizer_name_list then
                index = 1
            end
            break
        end
    end
    opts.name = visualizer_name_list[index]
    visualizer_hook()
end

mp.add_key_binding(cycle_key, "cycle-visualizer", cycle_visualizer)
