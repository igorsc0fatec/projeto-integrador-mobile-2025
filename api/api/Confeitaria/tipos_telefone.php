<?php
// tipos_telefone.php
require_once '../config.php';

$query = "SELECT id_tipo_telefone, tipo_telefone FROM tb_tipo_telefone ORDER BY tipo_telefone";
$result = $conn->query($query);

if ($result->num_rows > 0) {
    $tipos_arr = array();
    $tipos_arr["status"] = "success";
    $tipos_arr["data"] = array();

    while ($row = $result->fetch_assoc()) {
        $tipo_item = array(
            "id_tipo_telefone" => (int)$row['id_tipo_telefone'],
            "tipo_telefone" => $row['tipo_telefone']
        );
        array_push($tipos_arr["data"], $tipo_item);
    }

    http_response_code(200);
    echo json_encode($tipos_arr, JSON_NUMERIC_CHECK);
} else {
    http_response_code(404);
    echo json_encode(
        array("status" => "error", "message" => "Nenhum tipo de telefone encontrado.")
    );
}

$conn->close();
?>