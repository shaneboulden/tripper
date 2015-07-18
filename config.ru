require 'rubygems'
require 'sinatra'
require './main'
run Sinatra::Application
$stdout.sync = true
