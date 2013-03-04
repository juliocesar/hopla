# A Livereload task for Hopla
# ===========================
#
# This task adds Livereload for assets in Hopla. Changing any
# stylesheet of script will reload the browser.

# Be nice and announce myself.
Hopla.logger.info "Loading: #{__FILE__.colorize(:yellow)}"

# Keep this recipe's variables in a separate scope.
Hopla.LiveReload = OpenStruct.new

# Gems required for this extra.
gems = %w(listen em-websocket multi_json rack-livereload)
begin
  gems.map { |g| require g }
rescue LoadError
  STDERR.puts %Q(
    There are missing gems required for Hopla Livereload. Make sure you run:

    $ gem install #{gems.join(' ')}
  )
  exit 1
end

# Where websocket connections are going to be stored.
Hopla.LiveReload.sockets = []

# Add the Rack::LiveReload to Hopla's previw server stack
Hopla.middlewares << [Rack::LiveReload, :port => 35729, :no_swf => true]

# Sends down a message to LiveReload containing which assets
# to reload.
def reload_browser paths = []
  paths.each do |path|
    data = MultiJson.encode(['refresh', {
      :path           => '/stylesheets/hopla.css',
      :apply_js_live  => true,
      :apply_css_live => true
    }])
    puts "DATA: #{data.inspect}"
    Hopla.LiveReload.sockets.each { |ws| ws.send(data) }
  end
end

def start_ws_server
  EventMachine.run do
    Hopla.logger.info "Hopla LiveReload is waiting for browser connections"
    EventMachine.start_server('0.0.0.0', '35729', EventMachine::WebSocket::Connection, {}) do |ws|
      ws.onopen do
        begin
          puts "Browser connected"
          ws.send "!!ver:1.6"
          Hopla.LiveReload.sockets << ws
        rescue
          STDERR.puts $!
          STDERR.puts $!.backtrace
        end
      end

      ws.onmessage do |msg|
        puts "Browser URL: #{msg}"  if msg =~ /^(https?|file):/
      end

      ws.onclose do
        Hopla.LiveReload.sockets.delete ws
        puts "Browser disconnected"
      end
    end
  end
end

task :server_livereload do
  thread = Thread.new { start_ws_server }
  listener = Listen.to Hopla.Styles, :latency => 0.25, :force_polling => true
  listener.change do |modified, added, removed|
    begin
      reload_browser modified+added
    rescue Exception => e
      Hopla.logger.error e.message
      Hopla.logger.error e.backtrace
    end
  end
  Rake::Task['hopla:run'].invoke
  listener.start false
  thread.join
end
