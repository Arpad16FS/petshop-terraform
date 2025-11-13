#!/bin/bash
set -e

yum update -y
yum install -y gcc-c++ make sqlite sqlite-devel

curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs

mkdir -p /home/ec2-user/petshop-app/public
chown -R ec2-user:ec2-user /home/ec2-user/petshop-app
cd /home/ec2-user/petshop-app

cat << 'EOF' > app.js
const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const bodyParser = require('body-parser');
const path = require('path');
const app = express();
const db = new sqlite3.Database('appointments.db');

app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

db.run('CREATE TABLE IF NOT EXISTS appointments (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, service TEXT, date TEXT, time TEXT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)');

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.post('/book', (req, res) => {
  const { name, service, date, time } = req.body;
  db.run('INSERT INTO appointments (name, service, date, time) VALUES (?, ?, ?, ?)', [name, service, date, time], function(err) {
    if (err) {
      console.error(err);
      return res.status(500).send('Error al guardar la cita');
    }
    res.sendFile(path.join(__dirname, 'public', 'success.html'));
  });
});

const PORT = 8080;
app.listen(PORT, () => console.log('Petshop app running on port', PORT));
EOF

cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Petshop - Agenda tu cita</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="icon" href="/favicon.ico">
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
                <label class="form-label">Nombre</label>
                <input type="text" name="name" class="form-control form-control-lg" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Servicio</label>
                <select name="service" class="form-select form-select-lg" required>
                  <option value="Baño">Baño</option>
                  <option value="Corte">Corte</option>
                  <option value="Corte de uñas">Corte de uñas</option>
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
        <p class="text-center text-muted mt-3 small">Tu cita quedará registrada y verás una confirmación en pantalla.</p>
      </div>
    </div>
  </div>
</body>
</html>
EOF

cat << 'EOF' > public/style.css
body { font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial; }
.brand { color: #2e4a7d; }
EOF

# tiny favicon
printf '\x00\x00\x01\x00\x01\x00\x10\x10\x10\x00\x01\x00\x04\x00\x28\x01\x00\x00\x16\x00\x00\x00\x28\x00\x00\x00\x10\x00\x00\x00\x20\x00\x00\x00\x01\x00\x04\x00\x00\x00\x00\x00\xE0\x00\x00\x00\x12\x0B\x00\x00\x12\x0B\x00\x00\x10\x00\x00\x00\x10\x00\x00\x00' > public/favicon.ico

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
          <p>Tu turno fue asignado correctamente. ¡Gracias por confiar en nuestra peluquería de mascotas! 🐶✂️</p>
          <hr>
          <a href="/" class="btn btn-outline-primary">Volver</a>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
EOF

sudo -u ec2-user npm init -y
sudo -u ec2-user npm install express body-parser sqlite3

cat << 'EOF' > /etc/systemd/system/petshop.service
[Unit]
Description=Petshop Node.js App
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/petshop-app
ExecStart=/usr/bin/node /home/ec2-user/petshop-app/app.js
Restart=always
Environment=PORT=8080

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable petshop
systemctl start petshop
