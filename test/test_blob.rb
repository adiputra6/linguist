require 'linguist/file_blob'

require 'test/unit'
require 'mime/types'

class TestBlob < Test::Unit::TestCase
  include Linguist

  def fixtures_path
    File.expand_path("../fixtures/blob", __FILE__)
  end

  def blob(name)
    FileBlob.new(File.join(fixtures_path, name), fixtures_path)
  end

  def test_name
    assert_equal "foo.rb", blob("foo.rb").name
  end

  def test_pathname
    assert_equal Pathname.new("foo.rb"), blob("foo.rb").pathname
  end

  def test_mime_type
    assert_equal "application/ruby", blob("grit.rb").mime_type
    assert_equal "application/xml", blob("bar.xml").mime_type
    assert_equal "text/plain", blob("dog.o").mime_type
    assert_equal "application/sh", blob("script.sh").mime_type
  end

  def test_content_type
    assert_equal "text/plain; charset=utf-8", blob("grit.rb").content_type
    assert_equal "text/plain; charset=utf-8", blob("foo.pl").content_type
    assert_equal "text/plain; charset=utf-8", blob("bar.xml").content_type
    assert_equal "application/octet-stream", blob("dog.o").content_type
    assert_equal "text/plain; charset=utf-8", blob("script.sh").content_type
  end

  def test_disposition
    assert_equal "attachment; filename=foo.bin", blob("foo.bin").disposition
    assert_equal "attachment; filename=linguist.gem", blob("pkg/linguist.gem").disposition
    assert_equal "attachment; filename=foo+bar.jar", blob("foo bar.jar").disposition
    assert_equal "inline", blob("foo.txt").disposition
    assert_equal "inline", blob("grit.rb").disposition
  end

  def test_data
    assert_equal "module Foo\nend\n", blob("foo.rb").data
  end

  def test_lines
    assert_equal ["module Foo", "end", ""], blob("foo.rb").lines
  end

  def test_size
    assert_equal 15, blob("foo.rb").size
  end

  def test_loc
    assert_equal 3, blob("foo.rb").loc
  end

  def test_sloc
    assert_equal 2, blob("foo.rb").sloc
  end

  def test_binary
    assert blob("linguist.gem").binary?
    assert blob("git.deb").binary?
    assert blob("git.exe").binary?
    assert !blob("file.txt").binary?
    assert !blob("foo.rb").binary?
    assert !blob("octocat.png").binary?
    assert !blob("script.pl").binary?
  end

  def test_text
    assert blob("file.txt").text?
    assert blob("file.json").text?
    assert blob("script.sh").text?
  end

  def test_image
    assert blob("octocat.png").image?
    assert blob("octocat.jpg").image?
    assert blob("octocat.jpeg").image?
    assert blob("octocat.gif").image?
    assert !blob("octocat.psd").image?
  end

  def test_viewable
    assert blob("foo.rb").viewable?
    assert blob("script.pl").viewable?
    assert !blob("octocat.png").viewable?
    assert !blob("linguist.gem").viewable?
  end

  def test_generated
    assert !blob("README").generated?
    assert blob("MainMenu.xib").generated?
    assert blob("MainMenu.nib").generated?
    assert blob("project.pbxproj").generated?

    # Minified JS
    assert !blob("jquery-1.6.1.js").generated?
    assert blob("jquery-1.6.1.min.js").generated?

    # CoffeScript JS

    # These examples are to basic to tell
    assert !blob("coffee/empty.js").generated?
    assert !blob("coffee/hello.js").generated?

    assert blob("coffee/intro.js").generated?
    assert blob("coffee/classes.js").generated?
  end

  def test_vendored
    assert !blob("README").vendored?

    # Node depedencies
    assert blob("node_modules/coffee-script/lib/coffee-script.js").vendored?

    # Rails vendor/
    assert blob("vendor/plugins/will_paginate/lib/will_paginate.rb").vendored?

    # C deps
    assert blob("deps/http_parser/http_parser.c").vendored?
    assert blob("deps/v8/src/v8.h").vendored?

    # Prototype
    assert !blob("public/javascripts/application.js").vendored?
    assert blob("public/javascripts/prototype.js").vendored?
    assert blob("public/javascripts/effects.js").vendored?
    assert blob("public/javascripts/controls.js").vendored?
    assert blob("public/javascripts/dragdrop.js").vendored?

    # jQuery
    assert blob("jquery.js").vendored?
    assert blob("public/javascripts/jquery.js").vendored?
    assert blob("public/javascripts/jquery.min.js").vendored?
    assert blob("public/javascripts/jquery-1.5.2.js").vendored?
    assert blob("public/javascripts/jquery-1.6.1.js").vendored?
    assert blob("public/javascripts/jquery-1.6.1.min.js").vendored?
    assert !blob("public/javascripts/jquery.github.menu.js").vendored?

    # MooTools
    assert blob("public/javascripts/mootools-core-1.3.2-full-compat.js").vendored?
    assert blob("public/javascripts/mootools-core-1.3.2-full-compat-yc.js").vendored?

    # Dojo
    assert blob("public/javascripts/dojo.js").vendored?

    # MochiKit
    assert blob("public/javascripts/MochiKit.js").vendored?

    # YUI
    assert blob("public/javascripts/yahoo-dom-event.js").vendored?
    assert blob("public/javascripts/yahoo-min.js").vendored?
    assert blob("public/javascripts/yuiloader-dom-event.js").vendored?

    # LESS
    assert blob("public/javascripts/less-1.1.0.js").vendored?
    assert blob("public/javascripts/less-1.1.0.min.js").vendored?

    # WYS editors
    assert blob("public/javascripts/ckeditor.js").vendored?
    assert blob("public/javascripts/tiny_mce.js").vendored?
    assert blob("public/javascripts/tiny_mce_popup.js").vendored?
    assert blob("public/javascripts/tiny_mce_src.js").vendored?

    # Fabric
    assert blob("fabfile.py").vendored?
  end

  def test_indexable
    assert blob("file.txt").indexable?
    assert blob("foo.rb").indexable?
    assert !blob("defun.kt").indexable?
    assert !blob("github.po").indexable?
    assert !blob("dump.sql").indexable?
    assert !blob("linguist.gem").indexable?
  end

  def test_language
    assert_equal Language['Ruby'],        blob("foo.rb").language
    assert_equal Language['Ruby'],        blob("script.rb").language
    assert_equal Language['Text'],        blob("octocat.png").language
    assert_equal Language['Ruby'],        blob("wrong_shebang.rb").language
    assert_equal Language['C'],           blob("hello.c").language
    assert_equal Language['C'],           blob("hello.h").language
    assert_equal Language['C++'],         blob("hello.cpp").language
    assert_equal Language['C++'],         blob("bar.h").language
    assert_equal Language['C++'],         blob("bar.hpp").language
    assert_equal Language['Objective-C'], blob("hello.m").language
    assert_equal Language['Objective-C'], blob("Foo.m").language
    assert_equal Language['Objective-C'], blob("Foo.h").language
    assert_equal Language['Objective-C'], blob("FooAppDelegate.m").language
    assert_equal Language['Objective-C'], blob("FooAppDelegate.h").language
    assert_equal Language['GAS'],         blob("hello.s").language

    # Config files
    assert_equal Language['Shell'], blob(".profile").language
    assert_equal Language['Shell'], blob(".bashrc").language
    assert_equal Language['Shell'], blob(".bash_profile").language
    assert_equal Language['Shell'], blob(".zshrc").language
    assert_equal Language['Shell'], blob(".zlogin").language
    assert_equal Language['VimL'],  blob(".vimrc").language
    assert_equal Language['VimL'],  blob(".gvimrc").language
    assert_equal Language['INI'],   blob(".gitconfig").language
    assert_equal Language['YAML'],  blob(".gemrc").language
  end

  def test_lexer
    assert_equal Lexer['Ruby'], blob("grit.rb").lexer
    assert_equal Lexer['Text only'], blob("README").lexer
    assert_equal Lexer['Diff'], blob("dude-thing-okay--001.patch").lexer
    assert_equal Lexer['Scheme'], blob("dude.el").lexer
    assert_equal Lexer['JavaScript'], blob("dude.js").lexer
    assert_equal Lexer['Ruby'], blob("Capfile").lexer
  end

  def test_shebang_script
    assert_equal 'sh', blob("script.sh").shebang_script
    assert_equal 'bash', blob("script.bash").shebang_script
    assert_equal 'zsh', blob("script.zsh").shebang_script
    assert_equal 'perl', blob("script.pl").shebang_script
    assert_equal 'ruby', blob("script.rb").shebang_script
    assert_equal 'ruby', blob("script2.rb").shebang_script
    assert_equal 'python', blob("script.py").shebang_script
    assert_equal 'node', blob("script.js").shebang_script
    assert_equal 'groovy', blob("script.groovy").shebang_script
    assert_equal 'macruby', blob("script.mrb").shebang_script
    assert_equal 'rake', blob("script.rake").shebang_script
    assert_equal 'foo', blob("script.foo").shebang_script
    assert_equal 'nush', blob("script.nu").shebang_script
    assert_equal nil, blob("foo.rb").shebang_script
  end

  def test_shebang_language
    assert_equal Language['Shell'], blob("script.sh").shebang_language
    assert_equal Language['Shell'], blob("script.bash").shebang_language
    assert_equal Language['Shell'], blob("script.zsh").shebang_language
    assert_equal Language['Perl'], blob("script.pl").shebang_language
    assert_equal Language['Ruby'], blob("script.rb").shebang_language
    assert_equal Language['Python'], blob("script.py").shebang_language
    assert_equal Language['JavaScript'], blob("script.js").shebang_language
    assert_equal Language['Groovy'], blob("script.groovy").shebang_language
    assert_equal Language['Ruby'], blob("script.mrb").shebang_language
    assert_equal Language['Ruby'], blob("script.rake").shebang_language
    assert_equal Language['Nu'], blob("script.nu").shebang_language
    assert_equal nil, blob("script.foo").shebang_language
    assert_equal nil, blob("foo.rb").shebang_language
  end

  def test_colorize
    assert_equal <<-HTML, blob("foo.rb").colorize
<div class="highlight"><pre><span class="k">module</span> <span class="nn">Foo</span>
<span class="k">end</span>
</pre>
</div>
    HTML
  end

  def test_colorize_without_wrapper
    assert_equal <<-HTML, blob("foo.rb").colorize_without_wrapper
<span class="k">module</span> <span class="nn">Foo</span>
<span class="k">end</span>
    HTML
  end
end