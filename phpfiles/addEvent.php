<?php 
             $connect = new mysqli("localhost","root","","otobus");      
			 $driverphone = $_POST['driverphone'];
             $pick = $_POST['pick'];
             $dest = $_POST['dest'];
             $passengers = $_POST['passengers'];
             $eDate = $_POST['eDate'];
             $eTime = $_POST['eTime'];

    			$query = "INSERT INTO events (driverphone, pick,dest,passengers,eDate,eTime ) VALUES ('$driverphone','$pick','$dest','$passengers', '$eDate','$eTime')";
    			$inserted = mysqli_query($connect, $query);
    			
    			if($inserted == 1 ){  
				 
					$json['success'] = 1;
    				$json['value'] = 1;
					$json['error'] =0;
    				$json['message'] = 'تم ';
    			}else{
    				$json['value'] = 0;
					$json['error'] =1;
    				$json['message'] = 'فشل في الحفظ  ';
    			}

      		
			  echo json_encode($json);
			  mysqli_close($connect);  		
?>