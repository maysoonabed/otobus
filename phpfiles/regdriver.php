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
    
    $idcardImage = base64_decode($idcardimg);
    $licenseImage= base64_decode($licenseimg);
    file_put_contents('cardlic/'.$idcardname, $idcardImage);
    file_put_contents('cardlic/'.$licensename, $licenseImage);
    //echo "Image Uploaded Successfully.";
    /**************************************************/
    $query = "SELECT * FROM driver WHERE phonenum='$Mobile'";
    $result = mysqli_query($connect, $query);
    if(mysqli_num_rows($result)>0){
        $json['value'] = 2;
        $json['error'] =1;
        $json['message'] = '  رقم الهاتف مستخدم  ' .$Mobile;
        
    }else{
        $query1="INSERT INTO bus(busid ,type,idcard,numofpass)VALUES('$busid','$type','$idcardname','$numpass')";
        $inserted1 = mysqli_query($connect, $query1);
        $query2= "INSERT INTO driver(name, email, phonenum,busid,license,password) VALUES ('$Name','$Email','$Mobile','$busid','$licensename','$Password')";
        $inserted2 = mysqli_query($connect, $query2);
        	
    			if($inserted2 == 1 && $inserted1==1 ){   
    				$json['value'] = 1;
					$json['error'] =0;
    				$json['message'] = 'تم تسجيل معلوماتك بنجاح في انتظار موافقة المسؤول';
    			}else{
    				$json['value'] = 0;
					$json['error'] =1;
    				$json['message'] = 'فشل في إنشاء الحساب';
    			}
    }  
      echo json_encode($json);
      mysqli_close($connect);  	

?>