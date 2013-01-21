# encoding: UTF-8

# ὅπλα / Hopla - My weapons of choice
# ===========================
#
# A dev suite that lets you use templates (for gems you have installed)
# along with SASS/compass and CoffeeScript.
#
# Just install the gems listed in `rake hopla:gems`, then run
#
# $ rake hopla
#
# And you're all set! Make sure you're running ruby 1.9

# Dependencies
Gems         = %w(rack colorize rb-fsevent listen sass compass sprockets)
Dependencies = Gems + %w(pathname logger fileutils)
begin
  Dependencies.map { |lib| require lib }
rescue LoadError
  STDERR.puts %Q(
    Hopla says:

    Error loading one or more required gems. Ensure you have the required
    gems by running.

    $ gem install #{Gems.join ' '}

    Or add them to your Gemfile and run `bundle install`.
  )
  exit 1
end
# ---

# String / File.join hack to cut some characters
class String
  def /(to) File.join(self, to); end
end

# Paths we'll be referring to throughout
Root      = File.dirname __FILE__
Public    = Root/'public'
Assets    = Root/'assets'
Scripts   = Assets/'javascripts'
Styles    = Assets/'stylesheets'
Templates = Assets/'templates'

# Our pretty logger. A.k.a. the definition of going the extra mile.
class HoplaLogger < Logger
  def format_message severity, timestamp, program, message
    "  #{"————⥲".yellow}  %s" % message + "\n"
  end
end

# Steal everything coming out to stdout and ensure it conforms with
# our asthetic standards
def $stdout.puts *args
  $logger.info *args
end

$logger = HoplaLogger.new STDOUT
$logger.level = Logger::INFO
# ---

# The HTTP server
server = Rack::Builder.app do
  use Rack::Static,
    :urls => %w(/stylesheets /javascripts /images),
    :root => Root/'public'

  run lambda { |env|
    [ 200, { 'Content-Type' => 'text/html' }, File.open('public/index.html') ]
  }
end
# ---

# Helpers
def time
  time1 = Time.now
  yield
  time2 = Time.now
  time2 - time1
end

def compile_asset asset_path, destination
  duration = time { Compiler[asset_path].write_to Public/destination }
  $logger.info "Compiled #{asset_path.red} (#{duration}s)"
end

def compile_template template_path
  html_path = Public/(template_path.sub /.\w+$/, '.html')
  template = Tilt.new Templates/template_path
  FileUtils.mkdir_p File.dirname(html_path)
  duration = time do
    File.open(html_path, 'w') do |file|
      file.write template.render
    end
  end
  $logger.info "Compiled #{("templates"/template_path).red} (#{duration})"
end

def relativize_path path, from
  Pathname(path).relative_path_from(Pathname(from)).to_s
end
# ---

# The styles and scripts compiler
Compiler = Sprockets::Environment.new Pathname(Root) do |env|

  # Log to the standard output
  env.logger = $logger

  # Add all compass paths to it
  Compass.sass_engine_options[:load_paths].each do |path|
    env.prepend_path path.to_s
  end

  # Append the root path, so refs like javascripts/xyz also work
  env.prepend_path Scripts
  env.prepend_path Styles
  env.prepend_path Assets

  # Needed since Sprockets 2.5
  env.context_class.class_eval do
    def asset_path path, options = {}; path end
  end
end
# ---

# The callback that controls what happens when a file inside the assets
# dir changes
file_changed = lambda do |modified, added, removed|
  (modified + added).each do |asset_path|
    if /^javascripts/ =~ asset_path
      compile_asset asset_path, asset_path.sub(/.\w+$/, '.js')
    elsif /^stylesheets/ =~ asset_path
      compile_asset asset_path, asset_path.sub(/.\w+$/, '.css')
    else
      compile_template relativize_path(Assets/asset_path, Assets/'templates')
    end
  end

  # Removes compiled templates for templates that were deleted
  removed.each do |template_path|
    html_path = Public/template_path.sub(/.\w+$/, '.html')
    FileUtils.rm_f html_path
  end
end
# ---

namespace :hopla do
  # Runs Hopla
  task :run => [:check] do
    $logger.info "ὅπλα / Hopla starting. Listening on port 4567".red
    Listener = Listen.to Assets, :relative_paths => true
    Listener.change &file_changed
    Listener.start false
    Rack::Server.start :app => server, :Port => 4567
  end

  # Creates all the directories needed for Hopla
  task :setup do
    $logger.info "Creating necessary directories..."
    FileUtils.mkdir_p Scripts
    FileUtils.mkdir_p Styles
    FileUtils.mkdir_p Public
    FileUtils.mkdir_p Templates
  end

  # Checks whether the necessary directories exist
  task :check do
    needs_setup = [Scripts, Styles, Public, Templates].any? do |dir|
      not File.directory? dir
    end
    Rake::Task['hopla:setup'].invoke if needs_setup
  end
end

task :hopla => ['hopla:run']
