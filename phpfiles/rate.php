<?php 
             $connect = new mysqli("localhost","root","","otobus");      
             $Passid = $_POST['passid'];
             $Driverid = $_POST['driverid'];
             $Taq = $_POST['taq'];
             $Comment = $_POST['comment'];
             $Report = $_POST['report'];
    			$query = "INSERT INTO feedback (passid, driverid,taq,comment,report	) VALUES ('$Passid','$Driverid','$Taq','$Comment', '$Report')";
    			$inserted = mysqli_query($connect, $query);
    			
    			if($inserted == 1 ){  
					$json['success'] = 1;
    				$json['value'] = 1;
					$json['error'] =0;
    				$json['message'] = 'شكرًا لتعاونك';
    			}else{
    				$json['value'] = 0;
					$json['error'] =1;
    				$json['message'] = 'فشل في حفظ التقييم ';
    			}

      		
			  echo json_encode($json);
			  mysqli_close($connect);  		
?>