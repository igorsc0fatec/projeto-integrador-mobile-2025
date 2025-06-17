<?php
class Telefone {
    private $conn;
    private $table_name = "tb_telefone";

    public $id_telefone;
    public $num_telefone;
    public $id_usuario;
    public $id_ddd;
    public $id_tipo_telefone;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function read($id_usuario) {
        $query = "SELECT t.id_telefone, t.num_telefone, t.id_ddd, t.id_tipo_telefone, 
                 d.uf_ddd, tt.tipo_telefone
                 FROM " . $this->table_name . " t
                 LEFT JOIN tb_ddd d ON t.id_ddd = d.id_ddd
                 LEFT JOIN tb_tipo_telefone tt ON t.id_tipo_telefone = tt.id_tipo_telefone
                 WHERE t.id_usuario = ?
                 ORDER BY t.id_tipo_telefone";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $id_usuario);
        $stmt->execute();

        return $stmt;
    }

    public function create() {
        $query = "INSERT INTO " . $this->table_name . " 
                 SET num_telefone=:num_telefone, id_usuario=:id_usuario, 
                 id_ddd=:id_ddd, id_tipo_telefone=:id_tipo_telefone";

        $stmt = $this->conn->prepare($query);

        $this->num_telefone = htmlspecialchars(strip_tags($this->num_telefone));
        $this->id_usuario = htmlspecialchars(strip_tags($this->id_usuario));
        $this->id_ddd = htmlspecialchars(strip_tags($this->id_ddd));
        $this->id_tipo_telefone = htmlspecialchars(strip_tags($this->id_tipo_telefone));

        $stmt->bindParam(":num_telefone", $this->num_telefone);
        $stmt->bindParam(":id_usuario", $this->id_usuario);
        $stmt->bindParam(":id_ddd", $this->id_ddd);
        $stmt->bindParam(":id_tipo_telefone", $this->id_tipo_telefone);

        if ($stmt->execute()) {
            $this->id_telefone = $this->conn->lastInsertId();
            return true;
        }

        return false;
    }

    public function update() {
        $query = "UPDATE " . $this->table_name . " 
                 SET num_telefone=:num_telefone, id_ddd=:id_ddd, 
                 id_tipo_telefone=:id_tipo_telefone
                 WHERE id_telefone=:id_telefone";

        $stmt = $this->conn->prepare($query);

        $this->num_telefone = htmlspecialchars(strip_tags($this->num_telefone));
        $this->id_ddd = htmlspecialchars(strip_tags($this->id_ddd));
        $this->id_tipo_telefone = htmlspecialchars(strip_tags($this->id_tipo_telefone));
        $this->id_telefone = htmlspecialchars(strip_tags($this->id_telefone));

        $stmt->bindParam(":num_telefone", $this->num_telefone);
        $stmt->bindParam(":id_ddd", $this->id_ddd);
        $stmt->bindParam(":id_tipo_telefone", $this->id_tipo_telefone);
        $stmt->bindParam(":id_telefone", $this->id_telefone);

        return $stmt->execute();
    }

    public function delete() {
        $query = "DELETE FROM " . $this->table_name . " WHERE id_telefone = ?";

        $stmt = $this->conn->prepare($query);
        $this->id_telefone = htmlspecialchars(strip_tags($this->id_telefone));
        $stmt->bindParam(1, $this->id_telefone);

        return $stmt->execute();
    }

    public function numeroExists($exclude_id = null) {
        $query = "SELECT id_telefone FROM " . $this->table_name . " 
                 WHERE num_telefone = ? AND id_usuario = ?";
        
        if ($exclude_id) {
            $query .= " AND id_telefone != " . $exclude_id;
        }

        $stmt = $this->conn->prepare($query);
        $this->num_telefone = htmlspecialchars(strip_tags($this->num_telefone));
        $this->id_usuario = htmlspecialchars(strip_tags($this->id_usuario));

        $stmt->bindParam(1, $this->num_telefone);
        $stmt->bindParam(2, $this->id_usuario);
        $stmt->execute();

        return $stmt->rowCount() > 0;
    }

    public function countTelefones() {
        $query = "SELECT COUNT(*) as total FROM " . $this->table_name . " 
                 WHERE id_usuario = ?";
        
        $stmt = $this->conn->prepare($query);
        $this->id_usuario = htmlspecialchars(strip_tags($this->id_usuario));
        $stmt->bindParam(1, $this->id_usuario);
        $stmt->execute();

        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row['total'];
    }

    public function getUsuarioId() {
        $query = "SELECT id_usuario FROM " . $this->table_name . " 
                 WHERE id_telefone = ?";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->id_telefone);
        $stmt->execute();

        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        $this->id_usuario = $row['id_usuario'];
    }
}
?>