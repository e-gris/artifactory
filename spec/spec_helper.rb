RSpec.configure do |c|
  c.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

# require 'simplecov'
# require 'simplecov-console'

# SimpleCov.start do
#   add_filter '/spec'
#   add_filter '/vendor'
#   formatter SimpleCov::Formatter::MultiFormatter.new(
#     [
#       SimpleCov::Formatter::HTMLFormatter,
#       SimpleCov::Formatter::Console
#     ]
#   )
# end

RSpec.configure do |c|
  c.module_path = File.join(File.dirname(File.expand_path(__FILE__)),
                            'fixtures', 'modules')
  c.manifest_dir = File.join(File.dirname(File.expand_path(__FILE__)),
                             'fixtures', 'manifests')
  c.manifest = File.join(File.dirname(File.expand_path(__FILE__)),
                         'fixtures', 'manifests', 'site.pp')
  c.environmentpath = File.join(Dir.pwd, 'spec')
  #c.after(:suite) do
  #  RSpec::Puppet::Coverage.report!
  #end
end
