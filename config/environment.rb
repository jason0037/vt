# Load the rails application
require File.expand_path('../application', __FILE__)

ENV['JAVA_HOME'] = "/usr/bin/java"
# ENV['LD_LIBRARY_PATH'] = "#{ENV['JAVA_HOME']}/jre/lib"

# Initialize the rails application
Modengke::Application.initialize!

PIC_PATH= "/home/trade/pics/images"

