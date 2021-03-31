<?php
    $connect = mysqli_connect("localhost","root","","otobus");  
    $Email = $_POST['email'];
    $Name='';
    $Phone='';
    $Password='';
    $Image='';
    $cnt=0;
    if ($connect) {
       $json['error'] =0;   
       $query = "SELECT * FROM `passenger` WHERE `email`='$Email'";
       //echo $query;
       $result = $connect->query($query);
      //$result = mysqli_query($connect, $query);
       //echo $Email;
       //echo $query;
       echo $result->num_rows;
       
       if($result->num_rows>0){
         $json['error'] =0;
         $json['name'] =$result->name;
         $json['phonenum'] =$result->phonenum;
         $json['password'] =$result->password;
         $json['image'] ='';
       }else{
         $json['error'] =1;
         $json['message'] = 'ليس هناك نتائج';
       }
    }else 
       $json['message'] = 'هناك مشكلة في الاتصال بالسيرفر';

   echo json_encode($json);
   mysqli_close($connect);  
?>


