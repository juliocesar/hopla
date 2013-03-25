# Haml-Coffee template compiler for Hopla
# =======================================
#
# Uses the Listen gem to monitor assets/templates/jst, and
# fires `haml-coffee` at it. Best use with Sprockets is by
# then sourcing the generated templates.js file from your
# app's manifest.

# Be nice and announce myself.
Hopla.logger.info "Loading: #{__FILE__.colorize(:yellow)}"

# Ensure haml-coffee CLI can be found, or else bail.
if `which haml-coffee` == ''
  Hopla.logger.error %Q(
    The Haml-Coffee extra needs haml-coffee to be installed. Ensure
    you run:

    $ npm install -g haml-coffee
  )
  exit 1
end

# Ensure listen is loaded
begin
  require 'listen'
rescue LoadError
  STDERR.puts %Q(
    There are missing gems required for Hopla Haml-Coffee. Make sure you run:

    $ gem install listen
  )
  exit 1
end

# Since we need to Dir.chdir within the change block below in order for
# `haml-coffee` to generate appropriate paths for the templates in the
# namespace, store an absolute reference to the scripts path so we know
# where to put the compiled templates into.
absolute_scripts = File.dirname(__FILE__)/'..'/Hopla.Scripts

# Runs Hopla with the Haml-Coffee extra
task :server_hamlc do
  listener = Listen.to Hopla.Templates/'jst', :latency => 0.25, :force_polling => true
  listener.change do
    Dir.chdir Hopla.Templates/'jst'
    begin
      lines = `haml-coffee -i . -o #{absolute_scripts}/templates.js -n window.JST`
      lines.split(/\n/).each { |line| Hopla.logger.info line.sub(/^\s+/, '') }
    end
  end
  listener.start false
  Rake::Task['hopla:run'].invoke
end
