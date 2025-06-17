<?php
require_once '../config.php';

header('Content-Type: application/json');

// Captura o JSON recebido
$raw = file_get_contents("php://input");
$raw = trim($raw);
file_put_contents("debug_json.txt", $raw);

// Decodifica o JSON
$data = json_decode($raw);

if ($data === null) {
    echo json_encode([
        'status' => 'error',
        'message' => 'JSON inválido: ' . json_last_error_msg()
    ]);
    exit;
}

// Valida campos obrigatórios
if (!isset($data->id_telefone)) {
    echo json_encode(['status' => 'error', 'message' => 'id_telefone ausente']);
    exit;
}

if (!isset($data->num_telefone)) {
    echo json_encode(['status' => 'error', 'message' => 'num_telefone ausente']);
    exit;
}

if (!isset($data->id_ddd)) {
    echo json_encode(['status' => 'error', 'message' => 'id_ddd ausente']);
    exit;
}

if (!isset($data->id_tipo_telefone)) {
    echo json_encode(['status' => 'error', 'message' => 'id_tipo_telefone ausente']);
    exit;
}

// Atribui valores
$idTelefone = $data->id_telefone;
$numero = $data->num_telefone;
$idDdd = $data->id_ddd;
$idTipo = $data->id_tipo_telefone;

// Verifica se o telefone existe
$stmt = $conn->prepare("SELECT id_telefone FROM tb_telefone WHERE id_telefone = ?");
$stmt->bind_param("i", $idTelefone);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows == 0) {
    echo json_encode(['status' => 'error', 'message' => 'Telefone não encontrado']);
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->close();

// Atualiza o telefone
$stmt = $conn->prepare("UPDATE tb_telefone SET num_telefone = ?, id_ddd = ?, id_tipo_telefone = ? WHERE id_telefone = ?");
$stmt->bind_param("siii", $numero, $idDdd, $idTipo, $idTelefone);

if ($stmt->execute()) {
    echo json_encode([
        'status' => 'success',
        'message' => 'Telefone atualizado com sucesso'
    ]);
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Erro ao atualizar telefone: ' . $stmt->error
    ]);
}

$stmt->close();
$conn->close();