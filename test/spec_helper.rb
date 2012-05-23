require 'date'
require 'getoptlong'
require 'fileutils'
require 'yaml'
require 'pathname'
require 'rubygems'
require "stringio"
require 'open3'
require 'git'



require File.join(File.dirname(__FILE__), "..", "lib", "configuration", "deploy_configuration")
require File.join(File.dirname(__FILE__), "..", "lib", "deploy_dir" )
require File.join(File.dirname(__FILE__), "..", "lib", "deploy_logger" )
require File.join(File.dirname(__FILE__), "..", "lib", "kikubari" )
require File.join(File.dirname(__FILE__), "..", "lib", "deployer", "deployer" )
require File.join(File.dirname(__FILE__), "..", "lib", "deployer", "deployer_git" )
require File.join(File.dirname(__FILE__), "..", "lib", "deployer", "deployer_git_symfony" )
require File.join(File.dirname(__FILE__), "..", "lib", "deployer", "deployer_git_wordpress" )