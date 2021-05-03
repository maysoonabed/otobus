<?php
    $connect = mysqli_connect("localhost","root","","otobus");      
 
    $Phone = $_POST['phone'];

    if ($connect) {
        $query = "SELECT * FROM `driver` WHERE `phonenum`='$Phone'"; 
        $result = $connect->query($query);
            if($result->num_rows>0){
              $row = mysqli_fetch_assoc($result);
              $json['name']=$row['name'];
              $json['email']=$row['email'];
              if($row['picture']==null)
              $json['profpic'] ="";
              else
              $json['profpic'] =$row['picture'];
           }else{
            $query = "SELECT * FROM `passenger` WHERE `phonenum`='$Phone'";
            $result = $connect->query($query);
            $row = mysqli_fetch_assoc($result);
            $json['name']=$row['name'];
            $json['email']=$row['email'];
              if($row['pict']==null)
              $json['profpic'] ="";
              else
              $json['profpic'] =$row['pict'];
            } 
    }
    echo json_encode($json);
    mysqli_close($connect);
?>
