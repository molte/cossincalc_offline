module CosSinCalc
  class Triangle
    class Formatter
      class Latex
        # Initializes the LaTeX renderer.
        def initialize(formatter)
          @formatter = formatter
          @triangle  = formatter.triangle
        end
        
        # Returns the generated LaTeX code.
        def to_tex(filename = nil)
          document(@triangle.alt ? (<<-EOT) : document_content(filename))
#{document_content(filename ? filename + '-1' : nil)}

\\newpage
\\section*{Alternative triangle}
Another triangle can be constructed based on the variables given.\\\\[0.2 cm]

#{Latex.new(@triangle.alt.humanize(f.precision)).document_content(filename ? filename + '-2' : nil)}
EOT
        end
        
        # Saves the generated LaTeX to a TeX file.
        # The filename should be provided without the .tex extension.
        def save_tex(filename)
          File.open("#{filename}.tex", 'w') { |f| f.write(to_tex(filename)) }
        end
        
        # Saves the generated LaTeX to a TeX file and then converts it using pdflatex.
        # The filename should be provided without the .pdf extension.
        def save_pdf(filename)
          save_tex(filename)
          Dir.chdir(File.dirname(filename)) { `pdflatex "#{File.basename(filename)}.tex"` }
        end
        
        # Returns the content of the LaTeX document.
        def document_content(image_filename = nil)
          variable_table + "\\\\[0.2 cm]\n\n" + equations + "\n\n" + drawing(image_filename)
        end
        
        private
        # Shorthand-method referencing the associated formatter object.
        def f
          @formatter
        end
        
        # Wraps the variables calculated in a LaTeX table.
        def variable_table
          table = "\\begin{tabular}{ r r r r r }\n"
          table << ['Angles', 'Sides', 'Altitudes', 'Medians', 'Angle bisectors'].join(' & ') + " \\\\ \\hline\n"
          
          @triangle.each do |v|
            table << [ "$#{v.to_s.upcase}=#{format_angle(f.angle(v), @triangle.angles.unit)}$", "$#{v}=#{f.side(v)}$",
              "$h_#{v.to_s.upcase}=#{f.altitude(v)}$", "$m_#{v}=#{f.median(v)}$",
              "$t_#{v.to_s.upcase}=#{f.angle_bisector(v)}$" ].join(' & ') + " \\\\\n"
          end
          
          table << "\\end{tabular}"
        end
        
        # Adds the appropriate unit to the angle value.
        def format_angle(value, unit)
          value + case unit
          when :degree then '\degree'
          when :gon    then '\unit{gon}'
          when :radian then '\unit{radian}'
          end
        end
        
        # Formats the equation for embedding into a LaTeX document.
        def format_equation(latex, variables, angle_unit)
          latex.gsub! /@pi/, (angle_unit == :radian ? '\pi' :
            format_angle(CosSinCalc::Triangle::Formatter::UNIT_FACTORS[angle_unit].to_i.to_s, angle_unit))
          
          symbols = latex.gsub /[$@]\d/ do |match|
            v = variables[match[1..-1].to_i - 1]
            (match[0] == ?@ ? v.to_s.upcase : v.to_s)
          end
          
          values = latex.gsub /[$@]\d/ do |match|
            v = variables[match[1..-1].to_i - 1]
            (match[0] == ?@ ? format_angle(f.angle(v), angle_unit) : f.side(v))
          end.split('=').reverse.join('=')
          
          symbols + ' &= ' + values
        end
        
        # Returns the list of equations performed during calculation.
        def equations
          "\\begin{align*}\n" +
            @triangle.equations.map { |latex, vars| format_equation(latex, vars, @triangle.angles.unit) }.join("\\\\\n") +
            "\n\\end{align*}"
        end
        
        # Saves the associated drawing and returns the embedding LaTeX code.
        # If no filename is given no image will be saved (can be used in testing).
        def drawing(filename = nil)
          CosSinCalc::Triangle::Drawing.new(f).save_png(filename) if filename
          "\\begin{center}\n\\includegraphics[scale=0.4]{#{filename ? File.basename(filename) : 'placeholder'}}\n\\end{center}"
        end
        
        # Wraps the given LaTeX content into a LaTeX document ready to write to filesystem.
        def document(content)
          <<-EOT
\\documentclass{article}
\\usepackage{amsmath}
\\usepackage{amsfonts}
\\usepackage{graphicx}
\\usepackage{grffile}

\\DeclareMathSymbol{*}{\\mathbin}{symbols}{"01}
\\newcommand{\\unit}[1]{\\ensuremath{\\, \\mathrm{#1}}}
\\newcommand{\\degree}{\\ensuremath{^{\\circ}}}

% Uncomment to use a comma as the decimal separator (you would still write a period in the source).
% \\DeclareMathSymbol{,}{\\mathpunct}{letters}{"3B}
% \\DeclareMathSymbol{.}{\\mathord}{letters}{"3B}
% \\DeclareMathSymbol{\\decimal}{\\mathord}{letters}{"3A}

\\title{CosSinCalc Calculation Results}
\\author{Calculated by the CosSinCalc Triangle Calculator}

\\begin{document}
\\maketitle

#{content}

\\end{document}
EOT
        end
      end
    end
  end
end
