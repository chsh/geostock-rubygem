# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "geostock/version"

Gem::Specification.new do |s|
  s.name        = "geostock"
  s.version     = GeoStock::VERSION
  s.authors     = ["CHIKURA Shinsaku"]
  s.email       = ["chsh@thinq.jp"]
  s.homepage    = ""
  s.summary     = %q{GeoStock API for Ruby}
  s.description = %q{GeoStock API for Ruby}

  s.rubyforge_project = "geostock"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
