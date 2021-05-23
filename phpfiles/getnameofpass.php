<?php
 $connect = mysqli_connect("localhost","root","","otobus");      
 
 $Phone = $_POST['passphone'];

 $query = "SELECT * FROM `passenger` WHERE `phonenum`='$Phone'";
 $result = $connect->query($query);
      
 if($result->num_rows>0){
    $row = mysqli_fetch_assoc($result);
    $json['passname']=$row['name'];
 }

 echo json_encode($json);
 mysqli_close($connect);

?>