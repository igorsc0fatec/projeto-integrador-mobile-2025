<?php
include 'config.php';

$data = json_decode(file_get_contents("php://input"));

$email = $data->email;
$senha = $data->senha;

$query = "SELECT * FROM tb_usuario WHERE email_usuario = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    if (password_verify($senha, $user['senha_usuario'])) {
        // Verifica se o usuário é uma confeitaria
        if ($user['id_tipo_usuario'] == 3) { // 3 é o ID para Confeitaria
            // Busca o ID da confeitaria
            $query_confeitaria = "SELECT id_confeitaria FROM tb_confeitaria WHERE id_usuario = ?";
            $stmt_confeitaria = $conn->prepare($query_confeitaria);
            $stmt_confeitaria->bind_param("i", $user['id_usuario']);
            $stmt_confeitaria->execute();
            $result_confeitaria = $stmt_confeitaria->get_result();
            
            if ($result_confeitaria->num_rows > 0) {
                $confeitaria = $result_confeitaria->fetch_assoc();
                $user['id_confeitaria'] = $confeitaria['id_confeitaria'];
            }
            $stmt_confeitaria->close();
        }
        
        $response = array(
            'status' => 'success',
            'message' => 'Login realizado com sucesso',
            'user' => $user
        );
    } else {
        $response = array(
            'status' => 'error',
            'message' => 'Senha incorreta'
        );
    }
} else {
    $response = array(
        'status' => 'error',
        'message' => 'Usuário não encontrado'
    );
}

echo json_encode($response);
$stmt->close();
$conn->close();
?>