<?php 
             $connect = new mysqli("localhost","root","","otobus");      
             $Name = $_POST['name'];
             $Email = $_POST['email'];
             $Mobile = $_POST['phone'];
             $Password = md5($_POST['password']);   
			
    			$query = "INSERT INTO feedback (passid, driverid,taq,comment,report	) VALUES ('$Name','$Email','$Mobile','$Password')";
    			$inserted = mysqli_query($connect, $query);
    			
    			if($inserted == 1 ){  
					$to_email = $Email;
                    $subject = "مستخدم جديد";
                    $body ="أهلاً بك $Name كراكب جديد لدى أوتوباس ";
                    $headers = "From: otobus@gmail.com";
					//mail($to_email, $subject, $body, $headers);//if ( ){echo "Passenger added succ";} else {echo "Email sending failed...";}  			
					$json['success'] = 1;
    				$json['value'] = 1;
					$json['error'] =0;
    				$json['message'] = 'تم التسجيل بنجاح';
    			}else{
    				$json['value'] = 0;
					$json['error'] =1;
    				$json['message'] = 'فشل في إنشاء الحساب';
    			}

      		
			  echo json_encode($json);
			  mysqli_close($connect);  		
?>