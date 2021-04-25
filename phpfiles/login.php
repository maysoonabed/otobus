<?php
    $connect = mysqli_connect("localhost","root","","otobus");      
 
    $Email = $_POST['email'];
    $Password = md5($_POST['password']);   
    $idtype=(int)($_POST['id']);

    if ($connect) {
       $json['error'] =0;

       if($idtype==2){     
          $query = "SELECT * FROM `passenger` WHERE `email`='$Email' AND `password` ='$Password'";
       }else{
          $query = "SELECT * FROM `driver` WHERE `email`='$Email' AND `password` ='$Password'"; 
       }
      $result = $connect->query($query);
      
      if($result->num_rows>0){

         if($idtype==1){
             $driver = mysqli_fetch_array($result);
             $q = "SELECT * FROM `driver` WHERE `driverid`='$driver[0]' AND `active`=0b1";
             $res = $connect->query($q);
             if($res->num_rows>0){
               $json['value'] = 1;
               while($row = mysqli_fetch_assoc($result)){
               $json['name']=$row['name'];
               $json['phonenum'] =$row['phonenum'];
               //$json['insdate']=$row[''];
               }
             }else{
               $json['value'] = 2;
               $json['error'] =1;
               $json['message'] ='لم يتم تأكيد تسجيلك الرجاء الانتظار';
             }
        }else{
              $json['value'] = 1;
              $row = mysqli_fetch_assoc($result);
              $json['name']=$row['name'];
              $json['phonenum'] =$row['phonenum'];
              $json['profpic'] =$row['pict'];
              $json['error'] =0;
            }
            
     }else{
         $json['value'] = 2;
         $json['error'] =1;
         $json['message'] = 'الإيميل أو كلمة السر غير صحيحة'; 
      }
   } else {
      $json['error'] =1;
      $json['message'] = 'هناك مشكلة في الاتصال بالسيرفر';
  }  
   echo json_encode($json);
   mysqli_close($connect);  
?>


