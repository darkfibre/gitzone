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
      if File.exists?("#{location}.unsorted") then File.delete("#{location}.unsorted") end
        
      zoneFile = File.open("#{location}.unsorted", "w")
      
      soa = zoneAXFR[0]
      
      for i in 1..zoneAXFR.length
        unless zoneAXFR[i] == nil then zoneFile.puts zoneAXFR[i] end
      end
      
      zoneFile.close
      
      sortedData = File.readlines("#{location}.unsorted").sort
      sortedFile = File.open("#{location}.tmp", "w")
      
      sortedFile.puts soa
      sortedFile.puts sortedData
      sortedFile.close
      
      File.delete("#{location}.unsorted")
      
      File.rename("#{location}.tmp", "#{location}")
    else
      puts "#{location} does not exist yet, aborting"
    end
  end
end  

zoneList = read_config("#{File.dirname(__FILE__)}/config.yaml")

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
  
  unless g.status.changed.empty? then
    puts "Committing updates in #{locDir}"
    g.commit_all("Script triggered update for #{zoneList[locDir]}")
  else
    puts "No changes in #{locDir}"
  end

end
