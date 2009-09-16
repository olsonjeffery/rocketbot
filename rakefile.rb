#
# $Id$
#

require 'rake'
require 'rake/testtask'
require 'pathname'
require 'fileutils'
require 'bbh.rb'
include FileUtils

task :default => :mbuild do
end

task :specs => "specs:view" do
end

namespace :specs do
  desc "Run Server Specs"
  task :run do
    system "nant default.build runSpecs"
  end

  desc "Run and View Server Specs"
  task :view => :run do
    system "start Specs.html"
  end
end

# mono build stuff
booc = "mono lib/boo/booc.exe "
if Bbh.isWindowsPlatform
  booc = 'lib\boo\booc.exe '
end

mspec = 'Libraries\Machine\Specifications\Machine.Specifications.ConsoleRunner.exe'
if !Bbh.isWindowsPlatform
  mspec = Bbh.convertToPlatformSeparator('mono ' + mspec)
end


task :mbuild => ['projects:deploy']do
end


task :mclean => ['projects:remove_build_dir'] do
end

namespace :projects do
  buildDir = 'bin'
  
  desc 'build everything and copy scripts'
  task :deploy => :bin do
    scriptsPath = Bbh.convertToPlatformSeparator(buildDir + '\Scripts')
    fromPath = Bbh.convertToPlatformSeparator('src\Scripts')
    Bbh.createFolderIfNeeded(scriptsPath)
    Bbh.copyAllFilesFromTo(fromPath, scriptsPath)
    
    configName = 'RocketBot.config.xml'
    configSrcPath = Bbh.convertToPlatformSeparator('src/RocketBot/'+configName)
    configDestPath = Bbh.convertToPlatformSeparator(buildDir + '/' + configName)
    File.copy(configSrcPath, configDestPath)
  end

  desc 'create the build directory, if needed'
  task :create_build_dir do
    Bbh.createFolderIfNeeded(buildDir)
  end

  desc 'remove the build directory, if it exists'
  task :remove_build_dir do
    Bbh.removeFolderIfNeeded(buildDir)
  end

  desc 'build RocketBot'
  task :bin => :core do
    name = 'RocketBot'
    projFile = 'src/'+name+'/'+name+'.booproj'
    projDir = 'src/'+name
    sh booc + Bbh.outputTo(buildDir, name+'.exe') + Bbh.exeTarget + Bbh.referenceDependenciesInMSBuild(projFile, buildDir, true) + Bbh.findBooFilesIn(projDir)

    Bbh.copyNonGacDependenciesTo(buildDir, projFile, true)
  end

  desc 'build RocketBot.Core'
  task :core => :create_build_dir do
    name = 'RocketBot.Core'
    projFile = 'src/'+name+'/'+name+'.booproj'
    projDir = 'src/'+name
    sh booc + Bbh.outputTo(buildDir, name+'.dll') + Bbh.dllTarget + Bbh.referenceDependenciesInMSBuild(projFile, buildDir, true) + Bbh.findBooFilesIn(projDir)

    Bbh.copyNonGacDependenciesTo(buildDir, projFile, true)
  end
end
