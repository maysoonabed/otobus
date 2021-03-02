<?php
    $connect = mysqli_connect("localhost","root","","otobus");      
 
    $Mobile = $_POST['phone'];
    $Password = md5($_POST['password']);   
    $idtype=(int)($_POST['id']);
    //echo  $Password;

    if ($connect) {
       $json['error'] =0;
       if($idtype==2){     
          $query = "SELECT * FROM `passenger` WHERE `phonenum`='$Mobile' AND `password` ='$Password'";
       }else{
       $query = "SELECT * FROM `driver` WHERE `phonenum`='$Mobile' AND `password` ='$Password'"; 
       }
       //echo $query;
      $result = $connect->query($query);
      //$result = mysqli_query($connect, $query);
      //echo $result->num_rows;
      if($result->num_rows>0){
         $json['value'] = 1;
      }else{
         $json['value'] = 2;
         $json['message'] = 'رقم الهاتف أو كلمة المرور غير صحيحة';
         $json['error'] =1;
      }
   } else {
      $json['error'] =1;
      $json['message'] = 'هناك مشكلة في الاتصال بالسيرفر';
  }  
   echo json_encode($json);
   mysqli_close($connect);  
?>


