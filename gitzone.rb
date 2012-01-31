#!/usr/bin/env ruby

require 'rubygems'
require 'dnsruby'
require 'yaml'
require 'git'

$res = Dnsruby::ZoneTransfer.new
$res.transfer_type = Dnsruby::Types.AXFR

def read_config(cfgFile)
  config = YAML.load_file(cfgFile)
  
  configHash = {}
  
  config.each_key do |locDir|
    zonepair = {}
    
    config[locDir].each do |zone,ns|
      zonepair.store(zone, ns)
    end
    
    configHash.store(locDir, zonepair)
  end
  
  return configHash
end

def write_zone(zoneAXFR,location)
  if(zoneAXFR)
    if File.exists?("#{location}")
      if File.exists?("#{location}.tmp") then File.delete("#{location}.tmp") end
      
      zonefile = File.open("#{location}.tmp", "w")
      
      zoneAXFR.each do |rr|
        zonefile.puts rr.inspect
      end
      
      File.rename("#{location}.tmp", "#{location}")
    else
      puts "#{location} does not exist yet, aborting"
    end
  end
end  

zoneList = read_config("config.yaml")

zoneList.each_key do |locDir|
  puts "Working with #{locDir}"
  
  g = Git.init(working_dir = "#{locDir}")
  g.status
  
  zoneList[locDir].each do |zone,ns|
    puts "Setting nameserver to #{ns}"
    $res.server = ns
    
    location = "#{locDir}/#{zone}"
    
    puts "Performing AXFR of zone #{zone}"
    zoneAXFR = $res.transfer("#{zone}")

    puts "Writing #{zone} to #{location}"
    write_zone(zoneAXFR,location)
  end
  
  puts "Committing updates in #{locDir}"
  g.commit_all("Script triggered update for #{zoneList}")
end
