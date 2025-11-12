#!/bin/bash
set -e
yum update -y

# Instalar Node.js 16 (compatible con Amazon Linux 2)
curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs gcc-c++ make sqlite-devel iptables

APP_DIR=/home/ec2-user/petshop-app
mkdir -p $APP_DIR
chown ec2-user:ec2-user $APP_DIR
cd $APP_DIR

# Crear los archivos de la aplicación
cat > package.json <<'JSON'
{
  "name": "petshop-app",
  "version": "1.0.0",
  "main": "app.js",
  "dependencies": {
    "express": "^4.18.2",
    "sqlite3": "^5.1.6",
    "body-parser": "^1.20.2"
  }
}
JSON

cat > app.js <<'NODE'
const express = require('express');
const bodyParser = require('body-parser');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const app = express();
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
const dbFile = path.join(__dirname, 'appointments.db');
const db = new sqlite3.Database(dbFile);
db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS appointments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    owner_name TEXT,
    pet_name TEXT,
    date TEXT,
    time TEXT,
    service TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);
});
app.use('/', express.static(path.join(__dirname, 'public')));
app.post('/api/appointments', (req, res) => {
  const { owner_name, pet_name, date, time, service } = req.body;
  if (!date || !time || !service) {
    return res.status(400).json({ ok:false, message: 'date, time and service are required' });
  }
  const stmt = db.prepare('INSERT INTO appointments (owner_name, pet_name, date, time, service) VALUES (?, ?, ?, ?, ?)');
  stmt.run(owner_name || '', pet_name || '', date, time, service, function(err) {
    if (err) return res.status(500).json({ ok:false, message: 'DB error' });
    res.json({ ok:true, id: this.lastID, message: 'Turno asignado' });
  });
  stmt.finalize();
});
app.get('/api/appointments', (req, res) => {
  db.all('SELECT * FROM appointments ORDER BY created_at DESC', [], (err, rows) => {
    if (err) return res.status(500).json({ ok:false });
    res.json({ ok:true, rows });
  });
});
const PORT = 8080;
app.listen(PORT, () => console.log('Petshop app running on port', PORT));
NODE

mkdir -p public
cat > public/index.html <<'HTML'
<!doctype html><html><head><meta charset="utf-8"><title>Peluquería de Mascotas</title></head>
<body><h1>Peluquería de Mascotas</h1>
<form id="form"><label>Dueño<input name="owner_name"></label>
<label>Mascota<input name="pet_name"></label>
<label>Fecha<input type="date" name="date" required></label>
<label>Hora<input type="time" name="time" required></label>
<label>Servicio<select name="service" required>
<option value="">--Seleccione--</option><option>Corte</option><option>Baño</option><option>Corte de uñas</option><option>Baño + Corte</option></select></label>
<button type="submit">Agendar</button></form>
<div id="conf"></div>
<script>
const form=document.getElementById('form');const conf=document.getElementById('conf');
form.addEventListener('submit',async e=>{e.preventDefault();const data=Object.fromEntries(new FormData(form));
const resp=await fetch('/api/appointments',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)});
const json=await resp.json();conf.innerHTML=json.ok?'✅ Turno asignado: '+data.service+' el '+data.date+' '+data.time:'❌ Error';form.reset();});
</script></body></html>
HTML

# Instalar dependencias
sudo -u ec2-user npm install --production

# Crear el servicio systemd
cat > /etc/systemd/system/petshop.service <<'SERVICE'
[Unit]
Description=Petshop Node.js App
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/petshop-app
ExecStart=/usr/bin/node /home/ec2-user/petshop-app/app.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
SERVICE

# Redirigir tráfico del puerto 80 al 8080
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080

# Habilitar e iniciar servicio
systemctl daemon-reload
systemctl enable petshop
systemctl start petshop

