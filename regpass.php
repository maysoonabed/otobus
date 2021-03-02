<?php 
             $connect = new mysqli("localhost","root","","otobus");      
             $Name = $_POST['name'];
             $Email = $_POST['email'];
             $Mobile = $_POST['phone'];
             $Password = md5($_POST['password']);   
			    		
            $query = "SELECT * FROM passenger WHERE phonenum='$Mobile'";
        	$result = mysqli_query($connect, $query);
        	
    		if(mysqli_num_rows($result)>0){
    			$json['value'] = 2;
				$json['error'] =1;
    			$json['message'] = ' رقم الهاتف مستخدم' .$Mobile;
    			
    		}else{
    			$query = "INSERT INTO passenger (name, email, phonenum, password) VALUES ('$Name','$Email','$Mobile','$Password')";
    			$inserted = mysqli_query($connect, $query);
    			
    			if($inserted == 1 ){    			
					$json['success'] = 1;
    				$json['value'] = 1;
					$json['error'] =0;
    				$json['message'] = 'User Successfully Registered';
    			}else{
    				$json['value'] = 0;
					$json['error'] =1;
    				$json['message'] = 'فشل في إنشاء الحساب';
    			}

      		}
			  echo json_encode($json);
			  mysqli_close($connect);  		
?>