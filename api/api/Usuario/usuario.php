<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include '../config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        handleGetRequest();
        break;
    case 'POST':
        handlePostRequest();
        break;
    default:
        echo json_encode([
            'status' => 'error',
            'message' => 'Método não permitido'
        ]);
        exit;
}

function handleGetRequest() {
    global $conn;

    $idUsuario = isset($_GET['id_usuario']) ? intval($_GET['id_usuario']) : null;

    $sql = "SELECT * FROM tb_usuario";
    $params = [];

    if ($idUsuario) {
        $sql .= " WHERE id_usuario = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $idUsuario);
    } else {
        $stmt = $conn->prepare($sql);
    }

    try {
        $stmt->execute();
        $result = $stmt->get_result();

        $usuarios = [];
        while ($row = $result->fetch_assoc()) {
            $usuarios[] = [
                'id_usuario' => $row['id_usuario'],
                'email_usuario' => $row['email_usuario'],
                'email_verificado' => (bool)$row['email_verificado'],
                'conta_ativa' => (bool)$row['conta_ativa'],
                'online' => $row['online'],
                'data_criacao' => $row['data_criacao'],
                'id_tipo_usuario' => $row['id_tipo_usuario']
            ];
        }

        echo json_encode([
            'status' => 'success',
            'data' => $usuarios
        ]);

    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Erro ao buscar usuários: ' . $e->getMessage()
        ]);
    }
}

function handlePostRequest() {
    global $conn;

    $data = json_decode(file_get_contents("php://input"));

    if (!$data || !isset($data->email_usuario) || !isset($data->senha_usuario) || !isset($data->id_tipo_usuario)) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Dados obrigatórios ausentes'
        ]);
        exit;
    }

    $email = $data->email_usuario;
    $senha = password_hash($data->senha_usuario, PASSWORD_DEFAULT);
    $emailVerificado = isset($data->email_verificado) ? intval($data->email_verificado) : 0;
    $contaAtiva = isset($data->conta_ativa) ? intval($data->conta_ativa) : 1;
    $idTipoUsuario = intval($data->id_tipo_usuario);

    try {
        $stmt = $conn->prepare("INSERT INTO tb_usuario (email_usuario, email_verificado, conta_ativa, senha_usuario, id_tipo_usuario) VALUES (?, ?, ?, ?, ?)");
        $stmt->bind_param("siisi", $email, $emailVerificado, $contaAtiva, $senha, $idTipoUsuario);

        if ($stmt->execute()) {
            $id = $conn->insert_id;

            echo json_encode([
                'status' => 'success',
                'message' => 'Usuário cadastrado com sucesso',
                'data' => [
                    'id_usuario' => $id,
                    'email_usuario' => $email,
                    'email_verificado' => (bool)$emailVerificado,
                    'conta_ativa' => (bool)$contaAtiva,
                    'id_tipo_usuario' => $idTipoUsuario
                ]
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Erro ao cadastrar usuário'
            ]);
        }
    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Erro no servidor: ' . $e->getMessage()
        ]);
    }
}
?>
