# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rscalr/version"

Gem::Specification.new do |s|
  s.name        = "rscalr"
  s.version     = Rscalr::VERSION
  s.authors     = ["Nathan Smith"]
  s.email       = ["nate@branchout.com"]
  s.summary     = %q{Ruby implementation of the Scalr API}
  s.description = %q{Rscalr is a Ruby implementation of the Scalr API, written to interface cleanly with Chef and other internal release management tasks.}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end