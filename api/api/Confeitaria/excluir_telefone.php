<?php
require_once '../config.php';

// Tenta pegar o id_telefone via JSON (POST)
$data = json_decode(file_get_contents("php://input"));
$id_telefone = null;

// Primeiro tenta pegar do JSON
if ($data && isset($data->id_telefone)) {
    $id_telefone = $data->id_telefone;
}
// Se não, tenta pegar da URL (GET)
elseif (isset($_GET['id_telefone'])) {
    $id_telefone = $_GET['id_telefone'];
}

if (!$id_telefone) {
    echo json_encode(['status' => 'error', 'message' => 'ID do telefone não fornecido']);
    exit;
}

$stmt = $conn->prepare("DELETE FROM tb_telefone WHERE id_telefone = ?");
$stmt->bind_param("i", $id_telefone);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Telefone excluído com sucesso']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Erro ao excluir telefone']);
}

$stmt->close();
$conn->close();
