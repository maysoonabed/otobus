<?php 
             $connect = new mysqli("localhost","root","","otobus");      
             $Eid = $_POST['id'];
			 $PassPh = $_POST['passphone'];
			 $NewP = $_POST['newP'];
             $passN=$_POST['name'];
             $Passengers = $_POST['passengers'];
              
    			$query = "INSERT INTO eventsre (passphone, passengers,	id,passname ) VALUES ('$PassPh','$Passengers','$Eid','$passN' )";
    			$inserted = mysqli_query($connect, $query);
    			
    			if($inserted == 1 ){  
				
					$query = "UPDATE `events` SET `passengers`='$NewP' WHERE `id`='$Eid' ";
    			    $ind = mysqli_query($connect, $query);
					
					$json['success'] = 1;
    				$json['value'] = 1;
					$json['error'] =0;
    				$json['message'] = 'تم';
    			}else{
    				$json['value'] = 0;
					$json['error'] =1;
    				$json['message'] = 'فشل ';
    			}

      		
			  echo json_encode($json);
			  mysqli_close($connect);  		
?>