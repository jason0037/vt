desc "import bcom cert"
namespace :bcom do
	task :import_cert do
		require 'cocaine'
		# keytool -import -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit -keypass changeit -alias bocommca -file /home/imodec/app/modengke/lib/modec_pay/ext/bcom/root.cer 
		# line = Cocaine::CommandLine.new("keytool","-import -keystore :keystore -storepass :storepass -keypass :keypass -alias :alias -file :file")


		# keystore = File.expand_path ''

		# puts keystore

		# cert = File.expand_path '../../modec_pay/ext/bcom/root.cer', __FILE__

		# puts cert

		
		# puts line.command(:storepass=>'123456',:keypass=>'123456',:alias=>'bocommca', :file=>file)

		 #    $classpath = $filePath.":";
		 #    $classpath .= $filePath."jsse.jar:";
		 #    $classpath .= $filePath."ISFJ_v2_0_119_2_BAISC_JDK14.jar:";
		 #    $classpath .= $filePath."bocommapi1.2.1.jar:";
		 #    $classpath .= $filePath."bocomm-netsign1.8.jar";
			# $cmd  = "export LANG=zh_CN.GBK && java -classpath {$classpath} bocomm_sign \"{$config}\" \"{$message}\"";
			# $handle = popen($cmd, 'r');
			# while(!feof($handle)){
			# 	$merSignMsg .= fread($handle,1024);
			# }
			# pclose($handle);
			# if(preg_match('/<message>(.+)<\/message>/',$merSignMsg,$match)){
			# 	$merSignMsg = $match[1];
			# 	return $merSignMsg;
			# }
			# return false;

		bcom_path = File.expand_path '../../modec_pay/ext/bcom/', __FILE__

		bcom_path = "#{bcom_path}"

		class_path = "#{bcom_path}/:"
		class_path += "#{bcom_path}/jsse.jar:"
		class_path += "#{bcom_path}/ISFJ_v2_0_119_2_BAISC_JDK14.jar:"
		class_path += "#{bcom_path}/bocommapi1.2.1.jar:"
		class_path += "#{bcom_path}/bocomm-netsign1.8.jar"

		puts class_path
		
		xml_config = "#{bcom_path}/B2CMerchant.xml"

		puts xml_config

		msg = "name|good|add"

		puts "export LANG=zh_CN.GBK && java -classpath #{class_path} bocomm_sign \"#{xml_config}\" \"#{msg}\""


	end


	task :sign do

		require 'rjb'

		ext_bcom = File.expand_path '../../modec_pay/ext/bcom/', __FILE__

		libs = ['jsse','ISFJ_v2_0_119_2_BAISC_JDK14','bocommapi1.2.1','bocomm-netsign1.8']
		libs.each do |lib|
			Rjb::add_jar("#{ext_bcom}/#{lib}.jar")
		end
		
		Rjb::Import('com.bocom.netpay.b2cAPI.*')

	end
end

