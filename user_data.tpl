#!/bin/bash
set -eux

dnf update -y
dnf install -y nodejs npm

mkdir -p /home/ec2-user/petshop-app/public
chown -R ec2-user:ec2-user /home/ec2-user/petshop-app
cd /home/ec2-user/petshop-app

cat << 'EOF' > app.js
const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise');
const path = require('path');

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

const DB_HOST = process.env.DB_HOST;
const DB_USER = process.env.DB_USER;
const DB_PASS = process.env.DB_PASS;
const DB_NAME = process.env.DB_NAME;

async function getConnection() {
  return mysql.createConnection({
    host: DB_HOST,
    user: DB_USER,
    password: DB_PASS,
    database: DB_NAME,
  });
}

async function initDB() {
  const conn = await getConnection();
  await conn.execute(`
    CREATE TABLE IF NOT EXISTS appointments (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255),
      service VARCHAR(255),
      date VARCHAR(50),
      time VARCHAR(50),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
  await conn.end();
}

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.post('/book', async (req, res) => {
  const { name, service, date, time } = req.body;

  try {
    const conn = await getConnection();
    await conn.execute(
      "INSERT INTO appointments (name, service, date, time) VALUES (?, ?, ?, ?)",
      [name, service, date, time]
    );
    await conn.end();

    res.sendFile(path.join(__dirname, 'public', 'success.html'));
  } catch (err) {
    console.error("DB Error:", err);
    res.status(500).send("Error al guardar la cita");
  }
});

app.get('/appointments', async (req, res) => {
  try {
    const conn = await getConnection();
    const [rows] = await conn.execute("SELECT * FROM appointments ORDER BY id DESC");
    await conn.end();
    res.json(rows);
  } catch (err) {
    console.error("DB Error:", err);
    res.status(500).send("Error al obtener las citas");
  }
});

const PORT = 8080;

initDB().then(() => {
  app.listen(PORT, () => console.log("Petshop RDS v8-full running on port", PORT));
}).catch(err => {
  console.error("Failed to init DB:", err);
});
EOF

cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Petshop - Agenda tu cita</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/style.css">
</head>
<body class="bg-light">
  <div class="container py-5">
    <div class="row justify-content-center">
      <div class="col-lg-6">
        <div class="card shadow-lg rounded-4 border-0">
          <div class="card-body p-4">
            <div class="text-center mb-3">
              <h1 class="fw-bold brand">Peluquería de Mascotas</h1>
              <p class="text-muted mb-0">Agenda tu cita en minutos</p>
            </div>
            <form action="/book" method="POST" class="mt-3">
              <div class="mb-3">
                <label class="form-label">Nombre de tu mascota</label>
                <input type="text" name="name" class="form-control form-control-lg" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Servicio</label>
                <select name="service" class="form-select form-select-lg" required>
                  <option value="Baño">Baño</option>
                  <option value="Corte">Corte</option>
                  <option value="Corte de uñas">Corte de uñas</option>
                  <option value="Baño + Corte">Baño + Corte</option>
                </select>
              </div>
              <div class="row g-3">
                <div class="col-md-6">
                  <label class="form-label">Fecha</label>
                  <input type="date" name="date" class="form-control form-control-lg" required />
                </div>
                <div class="col-md-6">
                  <label class="form-label">Hora</label>
                  <input type="time" name="time" class="form-control form-control-lg" required />
                </div>
              </div>
              <button class="btn btn-primary btn-lg w-100 mt-4" type="submit">Agendar</button>
            </form>
          </div>
        </div>
        <p class="text-center text-muted mt-3 small">
          Tu cita quedará registrada en nuestra base de datos en AWS RDS (MySQL 8.0) y verás una confirmación en pantalla.
        </p>
      </div>
    </div>
  </div>
</body>
</html>
EOF

mkdir -p public

cat << 'EOF' > public/style.css
body { font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; }
.brand { color: #2e4a7d; }
EOF

cat << 'EOF' > public/success.html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Petshop - Cita agendada</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
  <div class="container py-5">
    <div class="row justify-content-center">
      <div class="col-lg-6">
        <div class="alert alert-success shadow-sm" role="alert">
          <h4 class="alert-heading">¡Cita agendada!</h4>
          <p>Tu turno fue asignado correctamente y se guardó en nuestra base de datos en AWS RDS (MySQL). ¡Gracias por confiar en nuestra peluquería de mascotas! 🐶✂️</p>
          <hr>
          <a href="/" class="btn btn-outline-primary">Volver al inicio</a>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
EOF

sudo -u ec2-user npm init -y
sudo -u ec2-user npm install express body-parser mysql2

cat << EOF > /etc/systemd/system/petshop.service
[Unit]
Description=Petshop Node.js App v8-full (RDS MySQL)
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/petshop-app
Environment=DB_HOST=${db_host}
Environment=DB_USER=${db_user}
Environment=DB_PASS=${db_pass}
Environment=DB_NAME=${db_name}
ExecStart=/usr/bin/node /home/ec2-user/petshop-app/app.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable petshop
systemctl start petshop
