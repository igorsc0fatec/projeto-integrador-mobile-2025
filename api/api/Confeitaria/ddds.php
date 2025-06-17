<?php
require_once '../config.php';

$query = "SELECT id_ddd, ddd, uf_ddd FROM tb_ddd ORDER BY ddd";
$result = $conn->query($query);

if ($result->num_rows > 0) {
    $ddds_arr = array();
    $ddds_arr["status"] = "success";
    $ddds_arr["data"] = array();

    while ($row = $result->fetch_assoc()) {
        // Garante que id_ddd seja enviado como número
        $ddd_item = array(
            "id_ddd" => (int)$row['id_ddd'], // Conversão explícita para int
            "ddd" => $row['ddd'],
            "uf_ddd" => $row['uf_ddd']
        );
        array_push($ddds_arr["data"], $ddd_item);
    }

    http_response_code(200);
    echo json_encode($ddds_arr, JSON_NUMERIC_CHECK); // Força números como números
} else {
    http_response_code(404);
    echo json_encode(
        array("status" => "error", "message" => "Nenhum DDD encontrado.")
    );
}

$conn->close();
?>