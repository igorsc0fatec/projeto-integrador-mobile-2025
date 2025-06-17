<?php
include 'config.php';

$data = json_decode(file_get_contents("php://input"));

$email = $data->email;
$senha = password_hash($data->senha, PASSWORD_DEFAULT);
$tipoUsuario = $data->tipoUsuario; // 2 para cliente

// Verificar se o email já existe
$checkQuery = "SELECT * FROM tb_usuario WHERE email_usuario = ?";
$checkStmt = $conn->prepare($checkQuery);
$checkStmt->bind_param("s", $email);
$checkStmt->execute();
$checkResult = $checkStmt->get_result();

if ($checkResult->num_rows > 0) {
    $response = array(
        'status' => 'error',
        'message' => 'Email já cadastrado'
    );
} else {
    // Inserir novo usuário
    $insertQuery = "INSERT INTO tb_usuario (email_usuario, senha_usuario, id_tipo_usuario, email_verificado, conta_ativa) 
                    VALUES (?, ?, ?, 0, 1)";
    $insertStmt = $conn->prepare($insertQuery);
    $insertStmt->bind_param("ssi", $email, $senha, $tipoUsuario);
    
    if ($insertStmt->execute()) {
        $userId = $conn->insert_id;
        
        // Inserir cliente (você pode adicionar mais campos depois)
        $clienteQuery = "INSERT INTO tb_cliente (nome_cliente, id_usuario) VALUES (?, ?)";
        $clienteStmt = $conn->prepare($clienteQuery);
        $nome = explode('@', $email)[0]; // Nome padrão baseado no email
        $clienteStmt->bind_param("si", $nome, $userId);
        $clienteStmt->execute();
        
        $response = array(
            'status' => 'success',
            'message' => 'Cadastro realizado com sucesso',
            'userId' => $userId
        );
    } else {
        $response = array(
            'status' => 'error',
            'message' => 'Erro ao cadastrar usuário'
        );
    }
    $insertStmt->close();
}

echo json_encode($response);
$checkStmt->close();
$conn->close();
?>