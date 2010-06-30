CosSinCalc
==========

CosSinCalc is a [web application](http://cossincalc.com/) able to calculate the variables of a triangle and even draw it for you!

This is an offline version of the calculator available as a Ruby gem.
You can use the included command line utility to generate a PDF page containing all the results, formulae and a drawing of the triangle, *or* you can include it as a library in your Ruby application and use just the features you care about.

The main features are:

*   Calculating the missing variables of the triangle
*   Calculating additional variables (ie. altitudes, medians, angle bisectors, area, circumference)
*   Generating an SVG or PNG (via [ImageMagick](http://www.imagemagick.org/)) drawing of the triangle
*   Generating a LaTeX or PDF (via `pdflatex`) document containing the calculations, the steps performed and a drawing.

Usage
-----

For instructions on how to use the command line utility, please run `cossincalc --help` after installation.

Basic usage through an `irb` console:

    >> require 'rubygems'
    => true
    >> require 'cossincalc'
    => true
    
    # Pass the known side and angle values to the initialization method as two
    # hashes. The valid keys (variable names) are :a, :b and :c.
    # It is important that you provide the values as strings as they wouldn't
    # be parsed and converted properly, otherwise.
    >> triangle = CosSinCalc::Triangle.new({ :a => "3.0", :c => "5" }, { :c => "90" })
    => #<CosSinCalc::Triangle:0x25058e8>
    
    >> triangle.calculate!
    => true
    
    # Fetch angle A, but in radians and unrounded.
    >> triangle.angle(:a)
    => 0.643501108793284
    
    # Fetch angle A in degrees and rounded.
    >> triangle.humanize.angle(:a)
    => "36.87"
    
    # Change the output precision.
    >> triangle.humanize(3).angle(:a)
    => "36.870"
    
    # Fetch another variable (side b).
    >> triangle.humanize.side(:b)
    => "4.00"
    
    # There are many available variables:
    # altitude(:c), median(:a), angle_bisector(:a), area(), circumference()

### Change angle unit ###
The default unit used for angles is degrees, however both radians and gon may be used.

    >> triangle = CosSinCalc::Triangle.new({ :a => "3.0", :c => "5" }, { :c => (Math::PI/2).to_s, :unit => :radian })
    => #<CosSinCalc::Triangle:0x25058e8>
    
    >> triangle = CosSinCalc::Triangle.new({ :a => "3.0", :c => "5" }, { :c => "100", :unit => :gon })
    => #<CosSinCalc::Triangle:0x25058e8>

Note that no unit is used for side values as it doesn't matter to the calculation.

### Generate an SVG or PNG drawing ###
    >> triangle = ...; triangle.calculate!
    => true
    
    # Save an SVG version of the drawing by initializing a new Drawing
    # instance and passing the name of the file to be created to the save_svg
    # method.
    >> CosSinCalc::Triangle::Drawing.new(triangle.humanize).save_svg('my-vector-drawing')
    => true
    
    # Save a PNG version of the drawing by initializing a new Drawing
    # instance and passing the name of the file to be created to the save_png
    # method.
    # In fact, an SVG file is created first and then converted to a PNG image
    # by ImageMagick. Make sure to have ImageMagick installed if you want to
    # use this feature.
    >> CosSinCalc::Triangle::Drawing.new(triangle.humanize).save_png('my-png-drawing')
    => true

### Generate a PDF document ###
    >> triangle = ...; triangle.calculate!
    => true
    
    # Pass the wanted filename to the save_pdf method of the Latex instance.
    # Make sure to have a LaTeX distribution installed (as well as the
    # amsmath, amsfonts and graphicx packages) if you want to make use
    # of this feature.
    >> CosSinCalc::Triangle::Formatter::Latex.new(triangle.humanize).save_pdf('my-result-document')
    => true

Installation
------------

To install it as a Ruby gem, please run

    gem install cossincalc

In order for this to work, you must have [Ruby](http://www.ruby-lang.org/) and [RubyGems](http://rubygems.org) installed.

- - -

Feature requests, ideas, questions etc. is recieved at <http://getsatisfaction.com/cossincalc>.  
Bugs should be submitted to the [issue tracker](http://github.com/molte/cossincalc_offline/issues).

Copyright (c) 2010 Molte Emil Strange Andersen, released under the MIT license.
