<?php
    $connect = mysqli_connect("localhost","root","","otobus");  
    $Email = $_POST['email'];
    $Name='';
    $Phone='';
    //$Image='';
    if ($connect) { 
       $query = "SELECT * FROM `passenger` WHERE `email`='$Email'";
       //echo $query;
       $result = $connect->query($query);
       
       
       if($result->num_rows>0){
         
         //echo $row;
         while(($row = mysqli_fetch_assoc($result) )){
         $Name =$row['name'];
         $Phone=$row['phonenum'];
         }
         $json['name']=$Name;
         $json['phonenum'] =$Phone;
         $json['error'] =0;
         //$json['image'] ='';
       }else{
         $json['error'] =1;
         $json['message'] = 'ليس هناك نتائج';
         $json['name'] ='';
         $json['phonenum'] ='';
         $json['password'] ='';
       }
    }else {
        $json['error'] =0;
       $json['message'] = 'هناك مشكلة في الاتصال بالسيرفر';
    }
   echo json_encode($json);
   mysqli_close($connect);  
?>


