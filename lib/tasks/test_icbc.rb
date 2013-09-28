#encoding:utf-8
interfaceName="ICBC_PERBANK_B2C"
interfaceVersion="1.0.0.11"

tran_data = 'PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iR0JLIiBzdGFuZGFsb25lPSJubyI/PjxCMkNSZXE+PGludGVyZmFjZU5hbWU+SUNCQ19QRVJCQU5LX0IyQzwvaW50ZXJmYWNlTmFtZT48aW50ZXJmYWNlVmVyc2lvbj4xLjAuMC4xMTwvaW50ZXJmYWNlVmVyc2lvbj48b3JkZXJJbmZvPjxvcmRlckRhdGU+MjAxMzA2MjYxMDI0MDk8L29yZGVyRGF0ZT48Y3VyVHlwZT4wMDE8L2N1clR5cGU+PG1lcklEPjEwMDFFQzIzODA3NzMzPC9tZXJJRD48c3ViT3JkZXJJbmZvTGlzdD48c3ViT3JkZXJJbmZvPjxvcmRlcmlkPjEzNzIyMTM0NDkzMDQyPC9vcmRlcmlkPjxhbW91bnQ+MjQ3MDAwPC9hbW91bnQ+PGluc3RhbGxtZW50VGltZXM+MTwvaW5zdGFsbG1lbnRUaW1lcz48bWVyQWNjdD4xMDAxMjU4MjE5MzAwNDM1MDI4PC9tZXJBY2N0Pjxnb29kc0lEPjwvZ29vZHNJRD48Z29vZHNOYW1lPsnMs8fJzMa3PC9nb29kc05hbWU+PGdvb2RzTnVtPjwvZ29vZHNOdW0+PGNhcnJpYWdlQW10PjwvY2FycmlhZ2VBbXQ+PC9zdWJPcmRlckluZm8+PC9zdWJPcmRlckluZm9MaXN0Pjwvb3JkZXJJbmZvPjxjdXN0b20+PHZlcmlmeUpvaW5GbGFnPjA8L3ZlcmlmeUpvaW5GbGFnPjxMYW5ndWFnZT5aSF9DTjwvTGFuZ3VhZ2U+PC9jdXN0b20+PG1lc3NhZ2U+PGNyZWRpdFR5cGU+MjwvY3JlZGl0VHlwZT48bm90aWZ5VHlwZT5IUzwvbm90aWZ5VHlwZT48cmVzdWx0VHlwZT4wPC9yZXN1bHRUeXBlPjxtZXJSZWZlcmVuY2U+Ki5pLW1vZGVjLmNvbTwvbWVyUmVmZXJlbmNlPjxtZXJDdXN0b21JcD41OC4yNDYuNDIuMjAyPC9tZXJDdXN0b21JcD48Z29vZHNUeXBlPjE8L2dvb2RzVHlwZT48bWVyQ3VzdG9tSUQ+PC9tZXJDdXN0b21JRD48bWVyQ3VzdG9tUGhvbmU+PC9tZXJDdXN0b21QaG9uZT48Z29vZHNBZGRyZXNzPjwvZ29vZHNBZGRyZXNzPjxtZXJPcmRlclJlbWFyaz48L21lck9yZGVyUmVtYXJrPjxtZXJIaW50PjwvbWVySGludD48cmVtYXJrMT48L3JlbWFyazE+PHJlbWFyazI+PC9yZW1hcmsyPjxtZXJVUkw+aHR0cDovL3d3dy5pLW1vZGVjLmNvbS9vcGVuYXBpL2VjdG9vbHNfcGF5bWVudC9wYXJzZS9iMmMvaWNiY3BheV9wYXltZW50X3BsdWdpbl9pY2JjL2NhbGxiYWNrLzwvbWVyVVJMPjxtZXJWQVI+dGVzdDwvbWVyVkFSPjwvbWVzc2FnZT48L0IyQ1JlcT4='
mer_sign_msg = 'd+Hg1MuuouAv6jDcEEcWbKTgIW/nLxpLJedQmcItPC+5VoWqv/0Wv/39T1TZ8lo431B1aGZkZcBMn5Xlqit2iS6iBpL4vaxs+VfhjzpiE/29V4CIKpD7UvNvMpqGI+I13+Q8x1OuesDkMF1AisdSGnAcvcJdZvO0sYo78NoWxE4='
mer_cert = 'MIIDATCCAemgAwIBAgIKYULKEHrkAFKs2zANBgkqhkiG9w0BAQUFADA2MR4wHAYDVQQDExVJQ0JDIENvcnBvcmF0ZSBTdWIgQ0ExFDASBgNVBAoTC2ljYmMuY29tLmNuMB4XDTEyMTEyMjAyMDczMVoXDTEzMTEyMjAyMDczMVowPDEVMBMGA1UEAxMMTW9kZWMuZS4xMDAxMQ0wCwYDVQQLEwQxMDAxMRQwEgYDVQQKEwtpY2JjLmNvbS5jbjCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA3K/Vy9BDX112rh0uYakFBc/gtPSLQ/rOTy6rCcUt3sqjhM8yAEMw8OY4Jc/pqFPNL1+zPDNn57szc5J4Odv4A6Qg4dNFGJT5BEz3NTX13XblBe2Vw3c64RlFlyNfPN93Pcs7blPErifLMwGt595otAZaHPMO6jN2UPh0FK7ZY5ECAwEAAaOBjjCBizAfBgNVHSMEGDAWgBT5yEXDU5MmNjGTL5QQ38hTPfZvnjBJBgNVHR8EQjBAMD6gPKA6pDgwNjEQMA4GA1UEAxMHY3JsNTQxOTEMMAoGA1UECxMDY3JsMRQwEgYDVQQKEwtpY2JjLmNvbS5jbjAdBgNVHQ4EFgQUFSdD2ox2MacMBzdvvygcfqOKdDMwDQYJKoZIhvcNAQEFBQADggEBAJAbtB+zqdTKZjEXCQ4Gd/bLiD7/TnA1Wa7rpmKwso9dqWOKjM9zDqszd30qb9ASmFazVssZPYJcyDnpJXFZg90NfuAz9P3bqZOMSodCOBnK/fx37rkKdnzULDMos7N4s5hvdi2CP2KGtmohVkJZSkuLz19M2V/JOrt4T9UseKuLdPK0okoqDKHtSCi8sA2vnqD4FiygsaAokoLDn5nka0tLsx9+dOkCLwSjdorSxCi1vcB8LA6q3j7WS7KH0Sw/N44r5/YP9cdY/K3m2MWm1uaZgyOBWOIbeBQ9W048zZnuSG3SvPJqt9Y+iTn0pTe50uiGkkmmfbQJs/0PbC/1zJE='




require 'active_support'
require 'pp'
require 'rjb'

# xml = ActiveSupport::Base64.decode64(tran_data)

# pp xml

@lib_jar_path = File.expand_path '../../modec_pay/ext/icbc', __FILE__

self_classpath = "#{@lib_jar_path}:"
self_classpath +="#{@lib_jar_path}/icbc.jar:"
self_classpath +="#{@lib_jar_path}/InfosecCrypto_Java1_02_JDK14+.jar:"
glob_classpath = "#{ENV['JAVA_HOME']}/lib:#{ENV['JAVA_HOME']}/jre/lib"

classpath = "#{self_classpath}#{glob_classpath}"
message = '<?xml version="1.0" encoding="GBK" standalone="no"?><B2CReq><interfaceName>ICBC_PERBANK_B2C</interfaceName><interfaceVersion>1.0.0.11</interfaceVersion><orderInfo><orderDate>20130605101655</orderDate><curType>001</curType><merID>1001EC23807733</merID><subOrderInfoList><subOrderInfo><orderid>13703983090285</orderid><amount type="integer">1798</amount><installmentTimes>1</installmentTimes><merAcct>1001258219300435028</merAcct><goodsID></goodsID><goodsName>摩登客订单(20130604094259)</goodsName><goodsNum></goodsNum><carriageAmt></carriageAmt></subOrderInfo></subOrderInfoList></orderInfo><custom><verifyJoinFlag>0</verifyJoinFlag><Language>ZH_CN</Language></custom><message><creditType>2</creditType><notifyType>HS</notifyType><resultType>0</resultType><merReference>*.i-modec.com</merReference><merCustomIp></merCustomIp><goodsType>1</goodsType><merCustomID></merCustomID><merCustomPhone></merCustomPhone><goodsAddress></goodsAddress><merOrderRemark></merOrderRemark><merHint>http://test2.i-modec.com/payments/13703983090285/icbc/callback</merHint><remark1></remark1><remark2></remark2><merURL>http://test2.i-modec.com/payments/13703983090285/icbc/notify</merURL><merVAR></merVAR></message></B2CReq>'

# pp message.encoding

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

xml = @return_value.base64dec(tran_data)
# xml = xml.encode("UTF-8","GBK").encode("GBK","UTF-8")

pp xml

# pp xml

# pp xml.encoding

key_file = "#{@lib_jar_path}/Modec.key"
cert_file = "#{@lib_jar_path}/Modec.crt"
key_passwd = '12345678'

byte_pass = key_passwd.bytes.map(&p).to_a
byte_src  = xml.bytes.map(&p).to_a
s = @return_value.sign(byte_src, byte_src.length, byte_key, byte_pass)

pp @return_value.base64enc(s).gsub("\n","") == mer_sign_msg

# pp "+++++++++++++++++++++++++++++++++++++++++++++"

# my_sign =  `export LANG=zh_CN.GBK && java -classpath #{classpath} icbc_sign #{key_file} #{key_passwd} "#{xml}"`
# my_sign =  my_sign.match(/<message>(.+)<\/message>/m)[1].gsub("\n","")

# pp mer_sign_msg
# pp "===================================================="
# pp my_sign

# pp "------------------------------------------------------------------------------------------------------------"

# my_cert = @return_value.base64enc(byte_cert).gsub("\n","")
# pp my_cert
# pp "==========================================="
# pp mer_cert

# pp my_cert == mer_cert

# pp my_sign == mer_sign_msg

notify_data = 'PD94bWwgIHZlcnNpb249IjEuMCIgZW5jb2Rpbmc9IkdCSyIgc3RhbmRhbG9uZT0ibm8iID8+PEIyQ1Jlcz48aW50ZXJmYWNlTmFtZT5JQ0JDX1BFUkJBTktfQjJDPC9pbnRlcmZhY2VOYW1lPjxpbnRlcmZhY2VWZXJzaW9uPjEuMC4wLjExPC9pbnRlcmZhY2VWZXJzaW9uPjxvcmRlckluZm8+PG9yZGVyRGF0ZT4yMDEzMDYyNjEwMjIxNjwvb3JkZXJEYXRlPjxjdXJUeXBlPjAwMTwvY3VyVHlwZT48bWVySUQ+MTAwMUVDMjM4MDc3MzM8L21lcklEPjxzdWJPcmRlckluZm9MaXN0PjxzdWJPcmRlckluZm8+PG9yZGVyaWQ+PC9vcmRlcmlkPjxhbW91bnQ+PC9hbW91bnQ+PGluc3RhbGxtZW50VGltZXM+PC9pbnN0YWxsbWVudFRpbWVzPjxtZXJBY2N0PjwvbWVyQWNjdD48dHJhblNlcmlhbE5vPjwvdHJhblNlcmlhbE5vPjwvc3ViT3JkZXJJbmZvPjwvc3ViT3JkZXJJbmZvTGlzdD48L29yZGVySW5mbz48Y3VzdG9tPjx2ZXJpZnlKb2luRmxhZz4wPC92ZXJpZnlKb2luRmxhZz48Sm9pbkZsYWc+PC9Kb2luRmxhZz48VXNlck51bT48L1VzZXJOdW0+PC9jdXN0b20+PGJhbms+PFRyYW5CYXRjaE5vPjwvVHJhbkJhdGNoTm8+PG5vdGlmeURhdGU+MjAxMzA2MjYxMDI2NTg8L25vdGlmeURhdGU+PHRyYW5TdGF0PjI8L3RyYW5TdGF0Pjxjb21tZW50PmZhaWx1cmUsRXJyb3JfY29kZTo5NjExMjAyOUVycm9yTXNnOlW23NHp1qTKp7Dco6zH69bY0MKwstewo6zI59PQzsrM4sfrwarPtbmk0NC/zbf+oaM8L2NvbW1lbnQ+PC9iYW5rPjwvQjJDUmVzPg=='
notify_sign = 'A9BDG4wAno68EGrRcOvsJxrejAwDucqGsz+yZIAuScBnZ/4TGm6KWHi9vhDGyYd3sCy1ugixkikTZt8ublHCDD8unFvYFNkIIxyAQ4rEwrdBoA9+cll0V+s33+E5iLWE6iPOEO3iXiYUW7mzllhQmgKMhLnsfKQ3rm85g5IZUmU='

notify_xml = @return_value.base64dec(notify_data)

notify_src = notify_xml.bytes.to_a
# pp notify_xml.encode("UTF-8","GBK")

notify_sign_dec = notify_src #@return_value.base64dec(notify_sign.bytes.to_a)


pp "======================================"
pp @return_value.verifySign(notify_src,notify_src.length,byte_cert,notify_sign_dec)  == 0








