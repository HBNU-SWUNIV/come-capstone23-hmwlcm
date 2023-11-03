<?php
$conn=mysqli_connect(
  'xx',
  'admin',
  'xx',
  'g2caps'
);
$querty=array();
$sql="select distinct local_1 from basicinfo";
$result=mysqli_query($conn,$sql);
if($result->num_rows>0){
  while($row=$result->fetch_assoc()){
    array_push($querty, $row["local_1"]);
    
  }
}


$conn->close();
echo json_encode(array('local_1' => $querty));
?>