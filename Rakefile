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
Gems         = %w(rack colorize compass sprockets nokogiri)
Dependencies = Gems + %w(pathname logger fileutils)
begin
  Dependencies.map { |lib| require lib }
rescue LoadError
  STDERR.puts %Q(
    Hopla says:

    Error loading one or more required gems. Ensure you have the required
    gems by running.

    $ gem install #{Gems.join ' '}

    Or add them to your Gemfile and run `bundle install`. Additionally, you
    may want to run:

    $ gem install haml coffee-script

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
Public    = 'public'
Assets    = 'assets'
Scripts   = Assets/'javascripts'
Styles    = Assets/'stylesheets'
Templates = Assets/'templates'

# Our pretty logger. A.k.a. the definition of going the extra mile.
class HoplaLogger < Logger
  def format_message severity, timestamp, program, message
    "  #{"————⥲".yellow}  %s" % message + "\n"
  end
end

# Steal everything going to stdout and ensure it conforms with
# our aesthetic standards
def $stdout.puts *args
  $logger.info *args
end

$logger = HoplaLogger.new STDOUT
$logger.level = Logger::INFO
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

# The preview server
server = Rack::Builder.app do
  FileServer = Rack::File.new Public

  # Tiny middleware for serving an index.html file for "directory"
  # paths. E.g.: serves '/coco/index.html' if you request '/coco/'.
  # It'll serve a compiled template for a request path should a static
  # HTML file not exist.
  Template = lambda { |env|
    env['PATH_INFO'] = '/' if ENV['FORCE_INDEX']
    noext    = env['PATH_INFO'].sub /\.\w+$/, ''
    path     = noext[-1] == "/" ? noext/'index' : noext
    static   = Dir["#{Public/path}.html"][0]
    template = Dir["#{Templates/path}.*"][0]
    if static
      [200, {'Content-Type' => 'text/html'}, File.open(static)]
    elsif template
      [200, {'Content-Type' => 'text/html'}, [Tilt.new(template).render]]
    else
      [404, {'Content-Type' => 'text/plain'}, ["Template not found: #{path}"]]
    end
  }

  # Serve, by priority:
  #   1 - any static files that exist in the public dir
  #   2 - scripts and stylesheets, compiling them before serving
  #   3 - index.html or compiled templates matching the path requested
  run lambda { |env|
    response = FileServer.call env
    response = Compiler.call env if response[0] == 404
    response = Template.call env if response[0] == 404
    response
  }
end
# ---

namespace :hopla do
  # Runs Hopla
  task :run => [:check] do
    $logger.info "ὅπλα / Hopla starting. Listening on port 4567".red
    Rack::Server.start :app => server, :Port => 4567
  end

  # Compiles all templates, and assets referred to in said templates
  task :compile do
    Dir["#{Templates}/**/*"].each do |template|
      target = Public/template.sub(Templates, '').sub(/.\w+$/, '.html')
      File.open(target, 'w') do |file| file << Tilt.new(template).render; end
      $logger.info "Compiled #{template.red}"
    end

    # For each HTML file in the public directory
    Dir["#{Public}/**/*.html"].each do |html|

      # .. open it with Nokogiri
      document = Nokogiri::HTML File.read(html)

      # ... get each script with a "src" attribute
      document.css('script[src]').each do |script|
        # ... if asset found in sprockets, compile/write it to public/
        if asset = Compiler[script['src'].sub(/^\//, '')]
          asset.write_to Public/script['src']
          $logger.info "Compiled #{script['src'].sub(/^\//, '').red}"
        end
      end

      # ... get each stylesheet
      document.css('link[rel="stylesheet"][href]').each do |css|
        # ... if asset found in sprockets, compile/write it to public/
        if asset = Compiler[css['href'].sub(/^\//, '')]
          asset.write_to Public/css['href']
          $logger.info "Compiled #{css['href'].sub(/^\//, '').red}"
        end
      end
    end
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
