<?php
$conn=mysqli_connect(
  'xx',
  'admin',
  'xx',
  'g2caps'
);
$placename = $_POST['placename'];
$sql = "SELECT local_2,name,img, expl,placequality,restaurant,historical,traffic,commodation,naturalview FROM basicinfo WHERE name = '$placename'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);
$data = array(
  'img' => $row['img'],
  'expl' => $row['expl'],
  'name' => $row['name'],
  'local_2' => $row['local_2'],
  'placequality' =>$row['placequality'],
  'restaurant' =>$row['restaurant'],
  'historical' =>$row['historical'],
  'traffic' =>$row['traffic'],
  'commodation' =>$row['commodation'],
  'naturalview' =>$row['naturalview']
);
mysqli_close($conn);
echo json_encode($data);
?>