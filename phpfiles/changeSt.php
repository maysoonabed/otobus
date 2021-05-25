<?php 
             $connect = new mysqli("localhost","root","","otobus");      
             $Eid = $_POST['id'];
             $Status = $_POST['status'];

    			$query = "UPDATE `events` SET `status`='$Status' WHERE `id`='$Eid'";
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