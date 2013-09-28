#encoding:utf-8
require 'rjb'
require 'pp'
# Rjb::load()

ext_bcom = File.expand_path '../../modec_pay/ext/bcom', __FILE__

# libs = ['jsse','ISFJ_v2_0_119_2_BAISC_JDK14','bocomm-netsign1.8','bocommapi1.2.1']
# libs.each do |lib|
# 	puts "add '#{ext_bcom}/#{lib}.jar'"
# 	Rjb::add_jar("#{ext_bcom}/#{lib}.jar")
# end

# require 'pp'

# client =  Rjb::import('com.bocom.netpay.b2cAPI.BOCOMB2CClient').new


# client.initialize("#{ext_bcom}/B2CMerchant.xml")


# net_server =  Rjb::import('com.bocom.netpay.b2cAPI.NetSignServer').new

# BOCOMSetting = Rjb::import('com.bocom.netpay.b2cAPI.BOCOMSetting')

# cert_dn = BOCOMSetting.MerchantCertDN

# pp BOCOMSetting.methods

# net_server.NSSetPlainText("name|good".encode('GBK'))

# pp net_server.NSDetachedSign(cert_dn).encode('GBK')



#  if ( is_dir( ROOT_DIR . '/data/cert/payment_plugin_icbc/' ) ) {
#             $libpath = ROOT_DIR . '/data/cert/payment_plugin_icbc/';
# }
# $self_classpath=$libpath.":";
# $self_classpath .= $libpath."/icbc.jar:";
# $self_classpath .= $libpath."/InfosecCrypto_Java1_02_JDK14+.jar:";
# $glob_classpath = getenv('CLASSPATH');
# $classpath = $self_classpath.':'.$glob_classpath;
# if (strtoupper(substr(PHP_OS,0,3))=="WIN"){
#     $classpath = str_replace(array('/',':'),array('\\',';'),$classpath);
#     $classpath = str_replace(";\\",":\\",$classpath);
#     $prikey = str_replace('/','\\',$prikey);
# }

# $message = addslashes($message);
# $cmd = "export LANG=zh_CN.GBK && java -classpath {$classpath} icbc_sign {$prikey} {$password} \"{$message}\"";
# //echo $cmd;
# //echo "<br>";
# $handle = popen($cmd, 'r');
# $merSignMsg = '';
# while(!feof($handle)){
#     $merSignMsg .= fread($handle,1024);
# }
# $merSignMsg = str_replace("\n","",$merSignMsg);



# ======== Icbc =======================
#javac -verbose -classpath lib/modec_pay/ext/icbc/icbc.jar:lib/modec_pay/ext/icbc/InfosecCrypto_Java1_02_JDK14+.jar lib/modec_pay/ext/icbc/icbc_sign.java

@lib_jar_path = File.expand_path '../../modec_pay/ext/icbc', __FILE__

self_classpath = "#{@lib_jar_path}:"
self_classpath +="#{@lib_jar_path}/icbc.jar:"
self_classpath +="#{@lib_jar_path}/InfosecCrypto_Java1_02_JDK14+.jar:"
glob_classpath = "#{ENV['JAVA_HOME']}/lib:#{ENV['JAVA_HOME']}/jre/lib"

classpath = "#{self_classpath}#{glob_classpath}"
message = '<?xml version="1.0" encoding="GBK" standalone="no"?><B2CReq><interfaceName>ICBC_PERBANK_B2C</interfaceName><interfaceVersion>1.0.0.11</interfaceVersion><orderInfo><orderDate>20130605101655</orderDate><curType>001</curType><merID>1001EC23807733</merID><subOrderInfoList><subOrderInfo><orderid>13703983090285</orderid><amount type="integer">1798</amount><installmentTimes>1</installmentTimes><merAcct>1001258219300435028</merAcct><goodsID></goodsID><goodsName>摩登客订单(20130604094259)</goodsName><goodsNum></goodsNum><carriageAmt></carriageAmt></subOrderInfo></subOrderInfoList></orderInfo><custom><verifyJoinFlag>0</verifyJoinFlag><Language>ZH_CN</Language></custom><message><creditType>2</creditType><notifyType>HS</notifyType><resultType>0</resultType><merReference>*.i-modec.com</merReference><merCustomIp></merCustomIp><goodsType>1</goodsType><merCustomID></merCustomID><merCustomPhone></merCustomPhone><goodsAddress></goodsAddress><merOrderRemark></merOrderRemark><merHint>http://test2.i-modec.com/payments/13703983090285/icbc/callback</merHint><remark1></remark1><remark2></remark2><merURL>http://test2.i-modec.com/payments/13703983090285/icbc/notify</merURL><merVAR></merVAR></message></B2CReq>'

key_file = "#{@lib_jar_path}/Modec.key"
cert_file = "#{@lib_jar_path}/Modec.crt"
key_passwd = '12345678'


sign =  `export LANG=zh_CN.GBK && java -classpath #{classpath} icbc_sign #{key_file} #{key_passwd} "#{message}"`
pp sign
sign =  sign.match(/<message>(.+)<\/message>/m)[1].gsub("\n","")

pp sign

pp `export LANG=zh_CN.GBK && java -classpath #{classpath} icbc_verify #{cert_file} "#{message}" #{sign}`






libs = ['icbc','InfosecCrypto_Java1_02_JDK14+']
libs.each do |lib|
	Rjb::add_jar("#{@lib_jar_path}/#{lib}.jar")
end
p = Proc.new do |x|
	x  =  x > 127 ? x -256 : x 
end

key_file = "#{@lib_jar_path}/Modec.key"
cert_file = "#{@lib_jar_path}/Modec.crt"

byte_key = File.binread(key_file).bytes.map(&p).to_a


byte_cert = File.binread(cert_file).bytes.map(&p).to_a


@return_value =  Rjb::import('cn.com.infosec.icbc.ReturnValue')
# pp @return_value.java_methods

src_string = '<?xml version="1.0" encoding="GBK" standalone="no"?><B2CReq><interfaceName>ICBC_PERBANK_B2C</interfaceName><interfaceVersion>1.0.0.11</interfaceVersion><orderInfo><orderDate>20130605101655</orderDate><curType>001</curType><merID>1001EC23807733</merID><subOrderInfoList><subOrderInfo><orderid>13703983090285</orderid><amount type="integer">1798</amount><installmentTimes>1</installmentTimes><merAcct>1001258219300435028</merAcct><goodsID></goodsID><goodsName>摩登客订单(20130604094259)</goodsName><goodsNum></goodsNum><carriageAmt></carriageAmt></subOrderInfo></subOrderInfoList></orderInfo><custom><verifyJoinFlag>0</verifyJoinFlag><Language>ZH_CN</Language></custom><message><creditType>2</creditType><notifyType>HS</notifyType><resultType>0</resultType><merReference>*.i-modec.com</merReference><merCustomIp></merCustomIp><goodsType>1</goodsType><merCustomID></merCustomID><merCustomPhone></merCustomPhone><goodsAddress></goodsAddress><merOrderRemark></merOrderRemark><merHint>http://test2.i-modec.com/payments/13703983090285/icbc/callback</merHint><remark1></remark1><remark2></remark2><merURL>http://test2.i-modec.com/payments/13703983090285/icbc/notify</merURL><merVAR></merVAR></message></B2CReq>'
byte_src = src_string.bytes.map(&p).to_a

# puts byte_src.join(",")


key_passwd = '12345678'
char_key = key_passwd.bytes.map(&p).to_a






tmp_sign = @return_value.sign(byte_src, byte_src.length,byte_key, char_key)



# pp @return_value.verifySign(byte_src,byte_src.length,byte_cert,tmp_sign)







