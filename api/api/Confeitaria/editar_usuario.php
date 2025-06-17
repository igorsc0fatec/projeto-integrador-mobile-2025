<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

include '../config02.php';

$input = json_decode(file_get_contents('php://input'), true);

// Validações básicas
if (empty($input['id_usuario'])) {
    echo json_encode(['status' => 'error', 'message' => 'ID do usuário é obrigatório']);
    exit;
}

if (empty($input['email_usuario'])) {
    echo json_encode(['status' => 'error', 'message' => 'E-mail é obrigatório']);
    exit;
}

try {
    // Verifica se o e-mail já existe para outro usuário
    $checkEmail = $conn->prepare("SELECT id_usuario FROM tb_usuario WHERE email_usuario = ? AND id_usuario != ?");
    $checkEmail->bind_param("si", $input['email_usuario'], $input['id_usuario']);
    $checkEmail->execute();
    
    if ($checkEmail->get_result()->num_rows > 0) {
        echo json_encode(['status' => 'error', 'message' => 'Este e-mail já está em uso por outro usuário']);
        exit;
    }

    // Atualização do e-mail
    $stmt = $conn->prepare("UPDATE tb_usuario SET email_usuario = ? WHERE id_usuario = ?");
    $stmt->bind_param("si", $input['email_usuario'], $input['id_usuario']);
    $stmt->execute();

    // Atualização de senha (se fornecida)
    if (!empty($input['senha_atual']) && !empty($input['nova_senha'])) {
        $checkPass = $conn->prepare("SELECT senha_usuario FROM tb_usuario WHERE id_usuario = ?");
        $checkPass->bind_param("i", $input['id_usuario']);
        $checkPass->execute();
        $result = $checkPass->get_result()->fetch_assoc();
        
        if (!password_verify($input['senha_atual'], $result['senha_usuario'])) {
            echo json_encode(['status' => 'error', 'message' => 'Senha atual incorreta']);
            exit;
        }
        
        $newHash = password_hash($input['nova_senha'], PASSWORD_DEFAULT);
        $updatePass = $conn->prepare("UPDATE tb_usuario SET senha_usuario = ? WHERE id_usuario = ?");
        $updatePass->bind_param("si", $newHash, $input['id_usuario']);
        $updatePass->execute();
    }

    // Retorna os dados atualizados
    $getUser = $conn->prepare("SELECT * FROM tb_usuario WHERE id_usuario = ?");
    $getUser->bind_param("i", $input['id_usuario']);
    $getUser->execute();
    $user = $getUser->get_result()->fetch_assoc();

    echo json_encode([
        'status' => 'success',
        'message' => 'Dados atualizados com sucesso!',
        'data' => $user
    ]);
    
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Erro no servidor: ' . $e->getMessage()]);
}
?>