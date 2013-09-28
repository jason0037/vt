import java.io.*;
import java.util.*; 
import cn.com.infosec.icbc.ReturnValue;
 
 class icbc_verify
 {
	 static public void main(String argv[])
	 {
		try
		{
			String pubCertFile = argv[0];
			String tranData = argv[1];
			String encData = argv[2];
			
			if( pubCertFile == "" || tranData == ""  || encData == "" )
			{
				return;
			}
			
			byte[] byteSrc = tranData.getBytes();
			byte[] EncSign = encData.getBytes();
			
		      FileInputStream in1 = new FileInputStream(pubCertFile);
	            byte[] bcert = new byte[in1.available()];
	            in1.read(bcert);
	            in1.close();

		      byte[] DecSign = ReturnValue.base64dec(EncSign);
	            int veriyCode = ReturnValue.verifySign(byteSrc,byteSrc.length,bcert,DecSign);
	            
	            int rnt = 0;
	            if( veriyCode == 0 ){
	                rnt = 1;
	            }else{
	                rnt = 0;
	            }
			System.out.print("<message>");
			System.out.print(rnt);
			System.out.print("</message>");
		}
		catch(Exception ex)
		{
			System.out.println(ex.getMessage());
		}
	 }
 }