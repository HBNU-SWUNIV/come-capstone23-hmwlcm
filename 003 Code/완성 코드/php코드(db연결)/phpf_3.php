<?php
$data = $_POST['data'];
$names = explode(',', $data);

// 데이터베이스 접속 및 쿼리 실행
$conn=mysqli_connect(
    'xx',
    'admin',
    'xx',
    'g2caps'
  );
$namesList = implode("', '", $names);
$sql = "SELECT time,local_2 FROM basicinfo WHERE name IN ('$namesList') ORDER BY FIELD(name, '$namesList')";
$result = mysqli_query($conn, $sql);

$data = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $item = array(
            'time' => $row['time'],
            'local_2'=>$row['local_2'],
            'X_lat'=>$row['X_lat'],
            'Y_lng'=>$row['Y_lng'],
        );
        array_push($data, $item);
    }
}

// 결과를 JSON 형식으로 반환
echo json_encode($data);

// 연결 종료
$conn->close();