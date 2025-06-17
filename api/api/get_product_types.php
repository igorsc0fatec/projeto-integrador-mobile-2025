<?php
include 'config.php';
header("Content-Type: application/json");

// Simula o ID do usuário logado (substitua com autenticação real)
$userId = $_GET['id_usuario'] ?? null;

if (!$userId) {
    echo json_encode(['status' => 'error', 'message' => 'Usuário não autenticado']);
    exit;
}

try {
    // Buscar ID da confeitaria do usuário logado
    $stmt = $conn->prepare("SELECT id_confeitaria FROM tb_confeitaria WHERE id_usuario = ?");
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    $confeitaria = $result->fetch_assoc();

    if (!$confeitaria) {
        echo json_encode(['status' => 'error', 'message' => 'Confeitaria não encontrada']);
        exit;
    }

    $idConfeitaria = $confeitaria['id_confeitaria'];

    // Buscar tipos de produto da confeitaria
    $stmt = $conn->prepare("SELECT id_tipo_produto, desc_tipo_produto FROM tb_tipo_produto WHERE id_confeitaria = ?");
    $stmt->bind_param("i", $idConfeitaria);
    $stmt->execute();
    $result = $stmt->get_result();

    $types = [];

    while ($row = $result->fetch_assoc()) {
        $types[] = [
            'id_tipo_produto' => $row['id_tipo_produto'],
            'desc_tipo' => $row['desc_tipo_produto']
        ];
    }

    echo json_encode(['status' => 'success', 'data' => $types]);
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}

$conn->close();
