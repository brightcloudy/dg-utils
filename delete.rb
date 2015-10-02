#!/usr/bin/env ruby
require 'trollop'
require 'droplet_kit'
require 'yaml'

opts = Trollop::options do
  banner <<-EOS
DigitalOcean Delete Droplet Utility

Usage:
    dg-delete [options] -n <droplet name>
where [options] include:
EOS
  opt :name, "Droplet name", :type => :string, :required => true, :short => "-n", :multi => false
  opt :config, "Configuration file", :default => String::new(".dgconfig"), :short => "-c"
  version "v0.1"
end

if !(File.exist?(opts[:config]))
  Trollop::die :config, "must exist"
end

Struct::new("DGConfig", :api_key, :account_name)

config_load = begin
  YAML.load(File.open(opts[:config]))
rescue ArgumentError => e
  Trollop::die :config, "invalid!"
end

client = DropletKit::Client.new(access_token: config_load[:api_key])

droplets = client.droplets.all

selected_drop = droplets.each.find { |drop| drop.name == opts[:name] }
Trollop::die "Droplet #{opts[:name]} not found on account" if selected_drop.nil?
puts "Droplet #{opts[:name]} - ID: #{selected_drop.id}"
