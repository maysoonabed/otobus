<?php
 $connect = mysqli_connect("localhost","root","","otobus");      
 
 $Phone = $_POST['passphone'];

 $query = "SELECT * from `passenger` WHERE phonenum ='$Phone'";
 $res = $con->query($query);
 $ro = mysqli_fetch_assoc($res);
 $reportcount = $ro['repcnt'] + 1;
 
 $sql = "UPDATE `passenger` SET report ='1' , repcnt ='$reportcount' WHERE `phonenum`='$Phone'";
 $ress = $connect->query($sql);

?>