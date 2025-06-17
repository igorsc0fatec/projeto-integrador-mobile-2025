<?php
require_once '../config.php';

$data = json_decode(file_get_contents("php://input"));

$raw = file_get_contents("php://input");
file_put_contents("debug_json.txt", $raw); // salva o JSON recebido num arquivo

$data = json_decode($raw);

if (!$data) {
    echo json_encode(['status' => 'error', 'message' => 'JSON não recebido ou malformado']);
    exit;
}

if (!isset($data->id_usuario)) {
    echo json_encode(['status' => 'error', 'message' => 'id_usuario ausente']);
    exit;
}

if (!isset($data->telefone)) {
    echo json_encode(['status' => 'error', 'message' => 'Objeto telefone ausente']);
    exit;
}

if (!isset($data->telefone->num_telefone)) {
    echo json_encode(['status' => 'error', 'message' => 'num_telefone ausente']);
    exit;
}


if (!isset($data->telefone->id_ddd)) {
    echo json_encode(['status' => 'error', 'message' => 'id_ddd ausente']);
    exit;
}

if (!isset($data->telefone->id_tipo_telefone)) {
    echo json_encode(['status' => 'error', 'message' => 'id_tipo_telefone ausente']);
    exit;
}

$idUsuario = $data->id_usuario;
$numero = $data->telefone->num_telefone;
$idDdd = $data->telefone->id_ddd;
$idTipo = $data->telefone->id_tipo_telefone;

$stmt = $conn->prepare("INSERT INTO tb_telefone (id_usuario, num_telefone, id_ddd, id_tipo_telefone) VALUES (?, ?, ?, ?)");
$stmt->bind_param("isii", $idUsuario, $numero, $idDdd, $idTipo);

if ($stmt->execute()) {
    echo json_encode([
        'status' => 'success',
        'message' => 'Telefone adicionado com sucesso'
    ]);
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Erro ao adicionar telefone: ' . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
