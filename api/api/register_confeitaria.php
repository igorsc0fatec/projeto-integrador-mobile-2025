<?php
include 'config.php';

$data = json_decode(file_get_contents("php://input"));

if (!$data || !isset($data->email) || !isset($data->senha)) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Dados inválidos ou ausentes'
    ]);
    exit;
}

// Dados básicos
$email = $data->email;
$senha = password_hash($data->senha, PASSWORD_DEFAULT);

// Constantes de criação
$idTipoUsuario = 3;       // 3 = Confeitaria
$emailVerificado = 1;     // E-mail começa não verificado
$contaAtiva = 1;          // Conta sempre ativa

// Dados da confeitaria
$nomeConfeitaria = $data->nomeConfeitaria;
$cnpj = $data->cnpj;
$cep = $data->cep;
$logradouro = $data->logradouro;
$numero = $data->numero;
$complemento = $data->complemento ?? null;
$bairro = $data->bairro;
$cidade = $data->cidade;
$uf = $data->uf;
$latitude = $data->latitude;
$longitude = $data->longitude;
$horaAbertura = $data->horaAbertura;
$horaFechamento = $data->horaFechamento;

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
                    VALUES (?, ?, ?, ?, ?)";
    $insertStmt = $conn->prepare($insertQuery);
    $insertStmt->bind_param("ssiii", $email, $senha, $idTipoUsuario, $emailVerificado, $contaAtiva);
    
    if ($insertStmt->execute()) {
        $userId = $conn->insert_id;
        
        // Inserir dados da confeitaria
        $confeitariaQuery = "INSERT INTO tb_confeitaria (
            nome_confeitaria, cnpj_confeitaria, cep_confeitaria, log_confeitaria, 
            num_local, complemento, bairro_confeitaria, cidade_confeitaria, 
            uf_confeitaria, latitude, longitude, hora_entrada, hora_saida, id_usuario
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        $confeitariaStmt = $conn->prepare($confeitariaQuery);
        $confeitariaStmt->bind_param(
            "sssssssssddssi",
            $nomeConfeitaria, $cnpj, $cep, $logradouro,
            $numero, $complemento, $bairro, $cidade,
            $uf, $latitude, $longitude, $horaAbertura, $horaFechamento, $userId
        );
        
        if ($confeitariaStmt->execute()) {
            $response = array(
                'status' => 'success',
                'message' => 'Confeitaria cadastrada com sucesso',
                'userId' => $userId
            );
        } else {
            // Remover usuário caso falhe
            $conn->query("DELETE FROM tb_usuario WHERE id_usuario = $userId");
            $response = array(
                'status' => 'error',
                'message' => 'Erro ao cadastrar dados da confeitaria'
            );
        }
        $confeitariaStmt->close();
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
