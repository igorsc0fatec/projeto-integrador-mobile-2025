<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config.php';

if (!isset($_GET['id_usuario'])) {
    http_response_code(400);
    echo json_encode(array(
        "status" => "error",
        "message" => "ID do usuário não fornecido"
    ));
    exit();
}

$id_usuario = $_GET['id_usuario'];

try {
    // Inclua tt.id_tipo_telefone na consulta
    $query = "SELECT t.id_telefone, t.num_telefone, t.id_ddd, d.ddd, d.uf_ddd, tt.id_tipo_telefone, tt.tipo_telefone
          FROM tb_telefone t
          LEFT JOIN tb_ddd d ON t.id_ddd = d.id_ddd
          LEFT JOIN tb_tipo_telefone tt ON t.id_tipo_telefone = tt.id_tipo_telefone
          WHERE t.id_usuario = ?";

    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $id_usuario);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $telefones_arr = array();
    $telefones_arr["status"] = "success";
    $telefones_arr["data"] = array();

    while ($row = $result->fetch_assoc()) {
        $telefone_item = array(
            "id_telefone" => $row['id_telefone'],
            "num_telefone" => $row['num_telefone'],
            "id_ddd" => $row['id_ddd'],
            "ddd" => $row['ddd'],
            "uf_ddd" => $row['uf_ddd'] ?? '',
            "id_tipo_telefone" => $row['id_tipo_telefone'] ?? null,
            "tipo_telefone" => $row['tipo_telefone'] ?? ''
        );
        array_push($telefones_arr["data"], $telefone_item);
    }

    http_response_code(200);
    echo json_encode($telefones_arr);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(array(
        "status" => "error",
        "message" => "Erro ao buscar telefones: " . $e->getMessage()
    ));
}
?>