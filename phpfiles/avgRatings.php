<?php 
             $connect = new mysqli("localhost","root","","otobus");      
             $Phone = $_POST['phone'];
           
             
					$q ="SELECT COUNT(*) AS cou FROM feedback WHERE `driverid`='$Phone' ";
					$res = $connect->query($q);
					if($res->num_rows>0){
					$rrw = mysqli_fetch_assoc($res);				
                    $json['cou']= $rrw['cou'];
					
                    $q ="SELECT COUNT(*) AS cnt1 FROM feedback WHERE `driverid`='$Phone'  AND `taq` ='1' ";
					$res = $connect->query($q);
					if($res->num_rows>0){
                     $rrw = mysqli_fetch_assoc($res);				
                     $json['cnt1']= $rrw['cnt1'];}

                     $q ="SELECT COUNT(*) AS cnt2 FROM feedback WHERE `driverid`='$Phone'  AND `taq` ='2' ";
                     $res = $connect->query($q);
                     if($res->num_rows>0){
                      $rrw = mysqli_fetch_assoc($res);				
                      $json['cnt2']= $rrw['cnt2'];}

                      $q ="SELECT COUNT(*) AS cnt3 FROM feedback WHERE `driverid`='$Phone'  AND `taq` ='3' ";
                      $res = $connect->query($q);
                      if($res->num_rows>0){
                       $rrw = mysqli_fetch_assoc($res);				
                       $json['cnt3']= $rrw['cnt3'];}

                       $q ="SELECT COUNT(*) AS cnt4 FROM feedback WHERE `driverid`='$Phone'  AND `taq` ='4' ";
                       $res = $connect->query($q);
                       if($res->num_rows>0){
                        $rrw = mysqli_fetch_assoc($res);				
                        $json['cnt4']= $rrw['cnt4'];}

                        $q ="SELECT COUNT(*) AS cnt5 FROM feedback WHERE `driverid`='$Phone'  AND `taq` ='5' ";
                        $res = $connect->query($q);
                        if($res->num_rows>0){
                         $rrw = mysqli_fetch_assoc($res);				
                         $json['cnt5']= $rrw['cnt5'];}




					$json['success'] = 1;
    				$json['value'] = 1;
					$json['error'] =0;
    				$json['message'] = 'تم';
    			}else{
    				$json['value'] = 0;
					$json['error'] =1;
    				$json['message'] = 'فشل';
    			}

      		
			  echo json_encode($json);
			  mysqli_close($connect);  		
?>