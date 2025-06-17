<?php
// api/Confeitaria/usuario.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, PUT");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        // Buscar dados do usuário através do id_confeitaria
        if (isset($_GET['id_confeitaria'])) {
            $idConfeitaria = $_GET['id_confeitaria'];
            
            // Primeiro, buscar o id_usuario na tabela tb_confeitaria
            $stmt = $conn->prepare("SELECT id_usuario FROM tb_confeitaria WHERE id_confeitaria = ?");
            $stmt->bind_param("i", $idConfeitaria);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows > 0) {
                $confeitaria = $result->fetch_assoc();
                $idUsuario = $confeitaria['id_usuario'];
                
                // Agora buscar os dados do usuário
                $stmt = $conn->prepare("SELECT u.*, tu.tipo_usuario 
                                      FROM tb_usuario u
                                      JOIN tb_tipo_usuario tu ON u.id_tipo_usuario = tu.id_tipo_usuario
                                      WHERE u.id_usuario = ?");
                $stmt->bind_param("i", $idUsuario);
                $stmt->execute();
                $result = $stmt->get_result();
                
                if ($result->num_rows > 0) {
                    $usuario = $result->fetch_assoc();
                    echo json_encode([
                        'status' => 'success',
                        'data' => $usuario
                    ]);
                } else {
                    echo json_encode([
                        'status' => 'error',
                        'message' => 'Usuário não encontrado'
                    ]);
                }
            } else {
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Confeitaria não encontrada'
                ]);
            }
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Parâmetro id_confeitaria não fornecido'
            ]);
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(['status' => 'error', 'message' => 'Método não permitido']);
        break;
}
?>