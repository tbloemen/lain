--[[

     Licensed under GNU General Public License v2
      * (c) 2013,      Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local helpers = require("lain.helpers")
local shell = require("awful.util").shell
local wibox = require("wibox")
local escape_f = require("awful.util").escape
local string = string

local function factory(args)
	args = args or {}

	local mpris = { widget = args.widget or wibox.widget.textbox() }
	local timeout = args.timeout or 2
	local settings = args.settings or function() end
	local cmd = "playerctl status && playerctl metadata"

	-- infos from mpris clients such as spotify and VLC
	-- based on https://github.com/acrisci/playerctl
	function mpris.update()
		helpers.async({ shell, "-c", cmd }, function(s)
			mpris_now = {
				art_url = "N/A",
				artist = "N/A",
				title = "N/A",
				album = "N/A",
				album_artist = "N/A",
			}

			mpris_now.state = string.match(s, "Playing") or string.match(s, "Paused") or "N/A"

			for line in string.gmatch(s, "[^\n]+") do
                for k, v in string.gmatch(line, "[%w]+:([%w]+)[%s]+(.*)$") do
                    if k == "artUrl" then
                        mpris_now.art_url = v
                    elseif k == "artist" then
                        mpris_now.artist = escape_f(v)
                    elseif k == "title" then
                        mpris_now.title = escape_f(v)
                    elseif k == "album" then
                        mpris_now.album = escape_f(v)
                    elseif k == "albumArtist" then
                        mpris_now.album_artist = escape_f(v)
                    end
                end
            end

			widget = mpris.widget
			settings()
		end)
	end

	mpris.timer = helpers.newtimer("mpris", timeout, mpris.update)

	return mpris
end

return factory
