<?php
$conn=mysqli_connect(
    'xx',
    'admin',
    'xx',
    'g2caps'
  );
$city = $_POST['city'];
$sql = "SELECT name, img FROM basicinfo WHERE local_1 = '$city'";
$result = mysqli_query($conn, $sql);


$data = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $item = array(
            'name' => $row['name'],
            'img' => $row['img']
        );
        array_push($data, $item);
    }
}

echo json_encode($data);


$conn->close();
?>