require "irb/ext/save-history"
IRB.conf[:SAVE_HISTORY] = 500
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"

begin
  require "pry"
  Pry.start
  exit
rescue LoadError => e
  warn "=> Unable to load pry"
end
