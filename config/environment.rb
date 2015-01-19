# Load the rails application
require File.expand_path('../application', __FILE__)

#ENV['JAVA_HOME'] = "/usr/bin/java"
#ENV['JAVA_HOME'] = "/usr/lib/jvm/jre-1.8.0-openjdk-1.8.0.25-1.b17.el6.x86_64"

ENV['JAVA_HOME'] = "/usr/java/jdk1.7.0_67"

ENV['LD_LIBRARY_PATH'] = "#{ENV['JAVA_HOME']}/jre/lib"

# Initialize the rails application
Modengke::Application.initialize!

PIC_PATH= "root/code/pics/images"

DATUM_PATH= "/root/code/datum"

