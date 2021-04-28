<?php
      $connect = mysqli_connect("localhost","root","","otobus");  
      $profpic=$_POST['profimg'];
      $profname=$_POST['profname'];
      $email=$_POST['email'];
      $profImage= base64_decode($profpic);
      file_put_contents('cardlic/'.$profname, $profImage);
      //adname ='$adminame', email = '$email', password ='".md5($password)."'WHERE email = '$prevemail'
      $query = "UPDATE `passenger` SET pict='$profname' WHERE email ='$email'";
      $result = mysqli_query($connect,$query);
      //if($result){echo "Yeees addddeddd"; echo "$email ___ $profname";}                                  
 ?>