<?php
    $connect = mysqli_connect("localhost","root","","otobus");      
 
    $Phone = $_POST['phone'];
    if ($connect) {
       $json['error'] =0;
          $query = "SELECT * FROM `driver` WHERE `phonenum`='$Phone'";       
      $res = $connect->query($query);
      
      if($res->num_rows>0){
               $json['value'] = 1;
               $rrw = mysqli_fetch_assoc($res);
               $json['name']=$rrw['name'];
               $json['profpic']=$rrw['picture'];
               $json['begN']=$rrw['begname'];
               $json['endN']=$rrw['endname'];
               $json['rate']=$rrw['taqyeem'];

               $busid=$rrw['busid'];        
               $quy = "SELECT * FROM `bus` WHERE `busid`='$busid'";
               $resu = $connect->query($quy);
               $rw=mysqli_fetch_assoc($resu);
               $json['busType']=$rw['type']; 
               $json['numOfPass']=$rw['numofpass']; 
               $json['message'] = 'تم سحب البيانات بنجاح'; 
            }else{
         $json['value'] = 2;
         $json['error'] =1;
         $json['message'] = 'حدثت مشكلة أثناء سحب البيانات'; 
      }
   } else {
      $json['error'] =1;
      $json['message'] = 'هناك مشكلة في الاتصال بالسيرفر';
  }  
   echo json_encode($json);
   mysqli_close($connect);  
?>


