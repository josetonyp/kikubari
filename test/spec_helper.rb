require 'date'
require 'getoptlong'
require 'fileutils'
require 'yaml'
require 'pathname'
require 'rubygems'
require "stringio"
require 'open3'
require 'git'

Dir[ File.join(File.dirname(__FILE__), *%w[.. lib ** *]) ].each{ |file| require file unless File.directory? file }