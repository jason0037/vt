puts File.expand_path '../ext/bcom',__FILE__ 
require 'pp'
require 'active_support/core_ext'

data =  Hash.from_xml '<?xml version="1.0" encoding="GBK" standalone="no"?>
<B2CRes>
	<interfaceName>1</interfaceName>
	<interfaceVersion>2</interfaceVersion>
	<orderInfo>
		<orderDate>3</orderDate>
		<curType></curType>
		<merID>4</merID>
		<subOrderInfoList>
			<subOrderInfo>
						<orderid>5</orderid>
						<amount>6</amount>
						<installmentTimes>1</installmentTimes>
						<merAcct>123131</merAcct>
						<tranSerialNo>1231</tranSerialNo>
			</subOrderInfo>
		</subOrderInfoList>
	</orderInfo>
	<custom>
		<verifyJoinFlag></verifyJoinFlag>
		<JoinFlag></JoinFlag>
		<UserNum></UserNum>
	</custom>
	<bank>
		<TranBatchNo></TranBatchNo>
		<notifyDate></notifyDate>
		<tranStat></tranStat>
		<comment></comment>
	</bank>
</B2CRes>'

pp data['B2CRes']['orderInfo']['subOrderInfoList']['subOrderInfo']['tranSerialNo']