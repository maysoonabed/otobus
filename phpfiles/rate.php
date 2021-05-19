<?php 
             $connect = new mysqli("localhost","root","","otobus");      
             $Passid = $_POST['passid'];
			 $PassP = $_POST['passphone'];

             $Driverid = $_POST['driverid'];
             $Taq = $_POST['taq'];
             $Comment = $_POST['comment'];
             $Report = $_POST['report'];
    			$query = "INSERT INTO feedback (passid, driverid,taq,comment,report,passphone ) VALUES ('$Passid','$Driverid','$Taq','$Comment', '$Report','$PassP')";
    			$inserted = mysqli_query($connect, $query);
    			
    			if($inserted == 1 ){  
					$q ="SELECT AVG(taq) AS avg FROM feedback WHERE `driverid`='$Driverid'";
					$res = $connect->query($q);
					if($res->num_rows>0){
					$rrw = mysqli_fetch_assoc($res);				
                    $av= $rrw['avg'];
					$query = "UPDATE `driver` SET `taqyeem`='$av' WHERE `phonenum`='$Driverid' ";
    			    $ind = mysqli_query($connect, $query);
					}
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