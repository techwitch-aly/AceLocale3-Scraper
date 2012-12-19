puts "Starting localizeAssist script..."
puts "Generating base locale (enUS) file for #{ARGV[0]}."
# make sure we ignore library files and other localization files
# since the base file is created before the loop, ensure that enUS files are ignored
IGNORE_DIRS = ["Locales", "Libs", "libs", "Localization", "Locale", "enUS"]
#open the new file to hold the enUS base locale
if ARGV[1] then
	localefile = File.open("Locales\\#{ARGV[1]}.lua", "w")
else
	localefile = File.open("Locales\\enUS.lua", "w")
end

# boilerplate header to warning about auto-generation
# also init the AceLocale library
localefile.puts <<EOF 
-- This file is script-generated and should not be manually edited. 
-- Localizers may copy this file to edit as necessary. 
local AceLocale = LibStub:GetLibrary("AceLocale-3.0") 
local L = AceLocale:NewLocale("#{ARGV[0]}", "enUS", true) 
if not L then return end 

EOF

#cache the matches so there are no repeats
stringcache = []
totals = 0
# for all lua files in the CWD and all child directories do...
Dir['**/*.lua'].each {|filename|
	valid = true
	IGNORE_DIRS.each {|d| if filename.match d then valid = false; break end }
	next unless valid
	
	localefile.puts "-- #{filename}"
	ct = 0
	File.open(filename, "r").each do |line|
		line.scan(/L\[\".*?(?<=\")\]/) {|match|
			#puts "Match '#{match}' in #{filename}"	#debug/processing text
			if not stringcache.include? match then
				stringcache.push match
				localefile.puts "#{match} = true"
				ct = ct + 1
				totals = totals + 1
			end
		}
	end
	#if we found no matches, file needs no localization
	localefile.puts "-- no localization" if ct == 0
	localefile.puts "\n"
}

puts "There were #{totals} localized strings found."