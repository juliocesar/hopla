# Instructions manual

## The gist

Hopla is basically Compass + Sprockets + a preview server, and multiple template engines made available outside of Ruby on Rails. It's perfect for making quick websites, or JavaScript applications. The idea was originally conceived with the preview server I built for [Tres](http://tres.io).

Hopla is _not_ distributed as a gem, and that's intentional: the idea is you'd start your project's `Rakefile` by downloading it, and adding further tasks on top.

## Running hopla

Download Hopla:

    $ wget https://raw.github.com/juliocesar/hopla.io/master/Rakefile

And then:

    $ rake hopla

What will likely happen is Hopla will tell you you need to install a few gems. Install them either by running the command as indicated in the output, or by adding the gems indicated to your `Gemfile` and calling `bundle install`.

Hopla will create the following directory structure:

    - assets
    \
      - javascripts
      - stylesheets
      - templates
    - public

_NOTE: Some JavaScript applications handle routing on the client-side. Which means you'll most likely render one "index" template at all times, and have JavaScript handle grabbing other templates and choosing which to render when. In those cases, you can run Hopla like so:

    $ rake hopla FORCE_INDEX=1

This will force the template in `assets/templates/index.*` OR `public/index.html` to
be rendered at all times.

## The `assets` dir

Anything in the assets dir is considered, well, an asset. Meaning, all CoffeeScripts/JavaScripts, SASS/CSS files, or templates of any kind should live here. Nothing will be served to the client unless you link it from a template.

What I usually do, for both scripts and styles, is I write a "manifest" file which
pulls what it needs in with Sprockets, so a single JavaScript and a single
stylesheet will be served as opposed to many. For an example, check Readlet's
[interactions](https://github.com/juliocesar/readlet/blob/master/assets/javascripts/readlet.coffee) CoffeeScript file, and it's [styles file](https://github.com/juliocesar/readlet/blob/master/assets/stylesheets/readlet.sass).

## The `templates` dir

Template rendering is handled by [Tilt](https://github.com/rtomayko/tilt). Which means as long as you have the necessary library installed for the template format you want (e.g.: the `haml` gem for `.haml` templates), it will Just Work™. So Jade,
Slim, etc, are all welcome.

If you create a template in `assets/templates/foo.haml`, visiting `http://localhost:4567/foo` will render it.

Try to avoid keeping static HTML files in here as Tilt won't know what to do with it. Keep them in the `public` dir instead.

## The `public` dir

This just acts like a common public directory. I keep my images and fonts in here.

Important: if you have a static HTML file in a path that's equivalent to a template
path (e.g.: templates/foo.haml exists and you also have public/foo.html), the static
file will take priority and be served instead.

## Compilation

You don't want to depend on Hopla to serve the application you built with it. I
wrote a rake task that compiles **what's required by the existing templates** into the `public` dir, so you can host it with a common webserver.

In the console, run:

    $ rake hopla:compile

Hopla will:

1. compile all templates in `assets/templates` into HTML.
2. parse each HTML file.
3. compile all styles and scripts sourced in them.

## Using Compass and other libraries

[Compass](http://compass-style.org/) is made available in the SASS path, but not automatically loaded. Which means in order to use it, you need to require it from your SASS files.

    @import 'compass/css3'

Any other libraries can be used by dropping them in the `assets/stylesheets` folder and `@import`ing them in the same way.

## Extras

Extras work like plugins. Hopla will load any Ruby file it finds in a `extras` folder within the project directory. Check the [extras](https://github.com/juliocesar/hopla.io/tree/master/extras) folder on GitHub for examples.

# Apps/sites built using it

* [Readlet](http://rdlet.com)
* [My personal website](http://awesomebydesign.com)

# License

It has none.
