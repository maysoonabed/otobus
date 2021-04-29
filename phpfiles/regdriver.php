<?php 
    $connect = mysqli_connect("localhost","root","","otobus"); 
	if(!$connect){
		echo"Database connection failed";		
	}
    /*************************************************/
    $Name = $_POST['name'];
    $Email = $_POST['email'];
    $Mobile = $_POST['phone'];
    $Password = md5($_POST['password']);  
    /**************************************************/
    $busid=$_POST['busId'];
    $numpass=$_POST['numpass'];
    $type=$_POST['type'];
    /*************************************************/
    $idcardimg = $_POST['idcardimg'];
    $idcardname= $_POST['idcardname'];
    $licenseimg = $_POST['licenseimg'];
    $licensename = $_POST['licensename'];
    $insurancimg=$_POST['insurancimg'];
    $insurancname=$_POST['insurancname'];
    $enddateStr=$_POST['enddate'];
    $time = strtotime($enddateStr);
    $enddate = date('Y-m-d',$time);
    $begname=$_POST['begname'];
    $beglat=(double)$_POST['beglat'];
    $beglng=(double)$_POST['beglng'];
    $endname=$_POST['endname'];
    $endlat=(double)$_POST['endlat'];
    $endlng=(double)$_POST['endlng'];

    $idcardImage = base64_decode($idcardimg);
    $licenseImage= base64_decode($licenseimg);
    $insurancImage=base64_decode($insurancimg);
    file_put_contents('cardlic/'.$idcardname, $idcardImage);
    file_put_contents('cardlic/'.$licensename, $licenseImage);
    file_put_contents('cardlic/'.$insurancname, $insurancImage);
    //echo "Image Uploaded Successfully.";
    /**************************************************/
    $query ="SELECT * FROM passenger p, driver d WHERE p.phonenum='$Mobile' or d.phonenum='$Mobile' or p.email='$Email' or d.email='$Email'";
    $result = mysqli_query($connect, $query);
    if(mysqli_num_rows($result)>0){
        $json['value'] = 2;
        $json['error'] =1;
        $json['message'] = 'رقم الهاتف أو البريد الإلكتروني مستخدم' ;
        
    }else{
        $query1="INSERT INTO bus(busid ,type,idcard,cardencoded,numofpass,insurend,insurname,insurencoded)VALUES('$busid','$type','$idcardname','$idcardimg','$numpass','$enddate','$insurancname','$insurancimg')";
        $inserted1 = mysqli_query($connect, $query1);
        $query2= "INSERT INTO driver(name, email, phonenum,busid,license,licencoded,password,begname,beglat,beglng,endname,endlat,endlng) VALUES ('$Name','$Email','$Mobile','$busid','$licensename','$licenseimg','$Password','$begname','$beglat','$beglng','$endname','$endlat','$endlng')";
        $inserted2 = mysqli_query($connect, $query2);
        	

    			if($inserted2 == 1 ){ //&& 
                    if($inserted1==1){  
    				$json['value'] = 1;
					$json['error'] =0;
    				$json['message'] = 'تم تسجيل معلوماتك بنجاح في انتظار موافقة المسؤول';
                    }
                    else{
                        $json['value'] = 1;
                        $json['error'] =1;
    				    $json['message'] = 'هذا الباص مُسجل سابقاً';
                    }
    			}else{
    				$json['value'] = 0;
					$json['error'] =1;
    				$json['message'] = 'فشل في إنشاء الحساب';
    			}
    }  
      echo json_encode($json);
      mysqli_close($connect);  	

?>