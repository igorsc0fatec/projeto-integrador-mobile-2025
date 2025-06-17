<?php
require_once '../config02.php'; // conexão via PDO

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: PUT, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$method = $_SERVER['REQUEST_METHOD'];

try {
    if ($method == 'PUT') {
        $input = json_decode(file_get_contents('php://input'), true);

        // Validação básica
        if (
            !isset($input['id_usuario']) ||
            !isset($input['email_usuario']) ||
            !isset($input['email_verificado']) ||
            !isset($input['conta_ativa']) ||
            !isset($input['senha_usuario']) ||
            !isset($input['id_tipo_usuario'])
        ) {
            echo json_encode(['status' => 'error', 'message' => 'Dados incompletos']);
            exit;
        }

        // Hash da senha
        $senhaHash = password_hash($input['senha_usuario'], PASSWORD_DEFAULT);

        // Atualizar o usuário
        $stmt = $pdo->prepare("
            UPDATE tb_usuario 
            SET 
                email_usuario = ?, 
                email_verificado = ?, 
                conta_ativa = ?, 
                senha_usuario = ?, 
                id_tipo_usuario = ?
            WHERE id_usuario = ?
        ");

        $stmt->execute([
            $input['email_usuario'],
            $input['email_verificado'],
            $input['conta_ativa'],
            $senhaHash,
            $input['id_tipo_usuario'],
            $input['id_usuario']
        ]);

        if ($stmt->rowCount() > 0) {
            echo json_encode(['status' => 'success', 'message' => 'Usuário atualizado com sucesso']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Nenhum usuário atualizado ou dados iguais']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Método não suportado']);
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Erro no servidor: ' . $e->getMessage()]);
}
?>
