<?php
    $connect = mysqli_connect("localhost","root","","otobus");      
 
    $Email = $_POST['email'];

    if ($connect) {
       // if($idtype==1){}else{ $query = "SELECT * FROM `driver` WHERE `email`='$Email'";
        $query = "SELECT * FROM `passenger` WHERE `email`='$Email'"; 
        $result = $connect->query($query);
            if($result->num_rows>0){
              $row = mysqli_fetch_assoc($result);
            //if($idtype==1){
              $json['name']=$row['name'];
              if($row['pict']==null)
              $json['profpic'] ="";
              else
              $json['profpic'] =$row['pict'];
           }else{
            $query = "SELECT * FROM `driver` WHERE `email`='$Email'";
            $result = $connect->query($query);
            $row = mysqli_fetch_assoc($result);
            $json['name']=$row['name'];
              if($row['picture']==null)
              $json['profpic'] ="";
              else
              $json['profpic'] =$row['picture'];
            } 
    }
    echo json_encode($json);
    mysqli_close($connect);
?>
