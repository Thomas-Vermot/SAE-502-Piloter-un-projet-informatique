#!/bin/bash

set -e

PROJECT="hopital-web"

echo "Création du projet $PROJECT..."

rm -rf "$PROJECT" "$PROJECT.zip"

mkdir -p "$PROJECT/public"

# ============================================================
# package.json
# ============================================================

cat > "$PROJECT/package.json" <<'EOF'
{
  "name": "hopital-web",
  "version": "1.0.0",
  "description": "Interface web de gestion de la base MariaDB hopital",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "node --watch server.js"
  },
  "dependencies": {
    "dotenv": "^16.4.7",
    "express": "^5.1.0",
    "mariadb": "^3.4.5"
  }
}
EOF

# ============================================================
# .env
# ============================================================

cat > "$PROJECT/.env" <<'EOF'
DB_HOST=localhost
DB_PORT=3306
DB_USER=USERNAME
DB_PASSWORD=PASSWORD
DB_NAME=hopital

PORT=3000
EOF

# ============================================================
# .gitignore
# ============================================================

cat > "$PROJECT/.gitignore" <<'EOF'
node_modules/
.env
EOF

# ============================================================
# server.js
# ============================================================

cat > "$PROJECT/server.js" <<'EOF'
require("dotenv").config();

const express = require("express");
const mariadb = require("mariadb");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;

const pool = mariadb.createPool({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    connectionLimit: 10
});

app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

// ============================================================
// TEST CONNEXION
// ============================================================

app.get("/api/test", async (req, res) => {

    let conn;

    try {

        conn = await pool.getConnection();

        await conn.query("SELECT 1");

        res.json({
            success: true,
            message: "Connexion MariaDB OK"
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            success: false,
            message: "Erreur de connexion MariaDB"
        });

    } finally {

        if (conn) conn.release();

    }
});

// ============================================================
// PATIENTS
// ============================================================

app.get("/api/patients", async (req, res) => {

    let conn;

    try {

        conn = await pool.getConnection();

        const rows = await conn.query(`
            SELECT
                ID,
                Nom,
                Prenom,
                Age,
                Contact,
                Groupe_Sanguin
            FROM Patient
            ORDER BY ID DESC
        `);

        res.json(rows);

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: "Erreur lors de la lecture des patients"
        });

    } finally {

        if (conn) conn.release();

    }
});


app.post("/api/patients", async (req, res) => {

    const {
        Nom,
        Prenom,
        Age,
        Contact,
        Groupe_Sanguin
    } = req.body;

    if (!Nom || !Prenom) {

        return res.status(400).json({
            message: "Le nom et le prénom sont obligatoires."
        });

    }

    let conn;

    try {

        conn = await pool.getConnection();

        const result = await conn.query(`
            INSERT INTO Patient
            (
                Nom,
                Prenom,
                Age,
                Contact,
                Groupe_Sanguin
            )
            VALUES (?, ?, ?, ?, ?)
        `, [
            Nom,
            Prenom,
            Age || null,
            Contact || null,
            Groupe_Sanguin || null
        ]);

        res.json({
            success: true,
            id: Number(result.insertId)
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: "Impossible d'ajouter le patient"
        });

    } finally {

        if (conn) conn.release();

    }
});

// ============================================================
// MEDECINS
// ============================================================

app.get("/api/medecins", async (req, res) => {

    let conn;

    try {

        conn = await pool.getConnection();

        const rows = await conn.query(`
            SELECT
                ID,
                Nom,
                Prenom,
                Specialite,
                Contact
            FROM Medecin
            ORDER BY ID DESC
        `);

        res.json(rows);

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: "Erreur lors de la lecture des médecins"
        });

    } finally {

        if (conn) conn.release();

    }
});


app.post("/api/medecins", async (req, res) => {

    const {
        Nom,
        Prenom,
        Specialite,
        Contact
    } = req.body;

    if (!Nom || !Prenom) {

        return res.status(400).json({
            message: "Le nom et le prénom sont obligatoires."
        });

    }

    let conn;

    try {

        conn = await pool.getConnection();

        const result = await conn.query(`
            INSERT INTO Medecin
            (
                Nom,
                Prenom,
                Specialite,
                Contact
            )
            VALUES (?, ?, ?, ?)
        `, [
            Nom,
            Prenom,
            Specialite || null,
            Contact || null
        ]);

        res.json({
            success: true,
            id: Number(result.insertId)
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: "Impossible d'ajouter le médecin"
        });

    } finally {

        if (conn) conn.release();

    }
});

// ============================================================
// ADMISSIONS
// ============================================================

app.get("/api/admissions", async (req, res) => {

    let conn;

    try {

        conn = await pool.getConnection();

        const rows = await conn.query(`
            SELECT
                A.ID,
                A.Id_Patient,
                CONCAT(P.Prenom, ' ', P.Nom) AS Patient,
                A.Date_Admission,
                A.Date_Depart,
                A.Raison_Admission,
                A.Chambre
            FROM Admission A
            LEFT JOIN Patient P
                ON P.ID = A.Id_Patient
            ORDER BY A.ID DESC
        `);

        res.json(rows);

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: "Erreur lors de la lecture des admissions"
        });

    } finally {

        if (conn) conn.release();

    }
});


app.post("/api/admissions", async (req, res) => {

    const {
        Id_Patient,
        Date_Admission,
        Date_Depart,
        Raison_Admission,
        Chambre
    } = req.body;

    if (!Id_Patient || !Date_Admission) {

        return res.status(400).json({
            message: "Le patient et la date d'admission sont obligatoires."
        });

    }

    let conn;

    try {

        conn = await pool.getConnection();

        const result = await conn.query(`
            INSERT INTO Admission
            (
                Id_Patient,
                Date_Admission,
                Date_Depart,
                Raison_Admission,
                Chambre
            )
            VALUES (?, ?, ?, ?, ?)
        `, [
            Id_Patient,
            Date_Admission,
            Date_Depart || null,
            Raison_Admission || null,
            Chambre || null
        ]);

        res.json({
            success: true,
            id: Number(result.insertId)
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: "Impossible d'ajouter l'admission"
        });

    } finally {

        if (conn) conn.release();

    }
});

// ============================================================
// OPERATIONS
// ============================================================

app.get("/api/operations", async (req, res) => {

    let conn;

    try {

        conn = await pool.getConnection();

        const rows = await conn.query(`
            SELECT
                O.ID,
                O.Id_Patient,
                CONCAT(P.Prenom, ' ', P.Nom) AS Patient,
                O.Id_Medecin,
                CONCAT(M.Prenom, ' ', M.Nom) AS Medecin,
                M.Specialite,
                O.Date
            FROM Operation O
            LEFT JOIN Patient P
                ON P.ID = O.Id_Patient
            LEFT JOIN Medecin M
                ON M.ID = O.Id_Medecin
            ORDER BY O.ID DESC
        `);

        res.json(rows);

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: "Erreur lors de la lecture des opérations"
        });

    } finally {

        if (conn) conn.release();

    }
});


app.post("/api/operations", async (req, res) => {

    const {
        Id_Patient,
        Id_Medecin,
        Date
    } = req.body;

    if (!Id_Patient || !Id_Medecin || !Date) {

        return res.status(400).json({
            message: "Le patient, le médecin et la date sont obligatoires."
        });

    }

    let conn;

    try {

        conn = await pool.getConnection();

        const result = await conn.query(`
            INSERT INTO Operation
            (
                Id_Patient,
                Id_Medecin,
                Date
            )
            VALUES (?, ?, ?)
        `, [
            Id_Patient,
            Id_Medecin,
            Date
        ]);

        res.json({
            success: true,
            id: Number(result.insertId)
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: "Impossible d'ajouter l'opération"
        });

    } finally {

        if (conn) conn.release();

    }
});

// ============================================================
// RFID
// ============================================================

app.get("/api/rfid", async (req, res) => {

    let conn;

    try {

        conn = await pool.getConnection();

        const rows = await conn.query(`
            SELECT
                ID,
                id_carte,
                Droits
            FROM RFID
            ORDER BY ID DESC
        `);

        res.json(rows);

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: "Erreur lors de la lecture des cartes RFID"
        });

    } finally {

        if (conn) conn.release();

    }
});


app.post("/api/rfid", async (req, res) => {

    const {
        id_carte,
        Droits
    } = req.body;

    if (!id_carte) {

        return res.status(400).json({
            message: "L'identifiant de la carte est obligatoire."
        });

    }

    let conn;

    try {

        conn = await pool.getConnection();

        const result = await conn.query(`
            INSERT INTO RFID
            (
                id_carte,
                Droits
            )
            VALUES (?, ?)
        `, [
            id_carte,
            Droits || null
        ]);

        res.json({
            success: true,
            id: Number(result.insertId)
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            message: "Impossible d'ajouter la carte RFID"
        });

    } finally {

        if (conn) conn.release();

    }
});

// ============================================================
// SERVEUR
// ============================================================

app.listen(PORT, () => {

    console.log("");
    console.log("======================================");
    console.log("       APPLICATION HOPITAL");
    console.log("======================================");
    console.log("");
    console.log(`Application : http://localhost:${PORT}`);
    console.log("");

});
EOF

# ============================================================
# public/index.html
# ============================================================

cat > "$PROJECT/public/index.html" <<'EOF'
<!DOCTYPE html>

<html lang="fr">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Gestion Hôpital</title>

    <link rel="stylesheet" href="style.css">

</head>

<body>

<div class="app">

    <aside class="sidebar">

        <h1>🏥 Hôpital</h1>

        <nav>

            <button onclick="showPage('dashboard')">
                📊 Tableau de bord
            </button>

            <button onclick="showPage('patients')">
                👤 Patients
            </button>

            <button onclick="showPage('medecins')">
                👨‍⚕️ Médecins
            </button>

            <button onclick="showPage('admissions')">
                🏥 Admissions
            </button>

            <button onclick="showPage('operations')">
                ⚕️ Opérations
            </button>

            <button onclick="showPage('rfid')">
                💳 RFID
            </button>

        </nav>

    </aside>


    <main class="content">

        <!-- DASHBOARD -->

        <section id="dashboard" class="page">

            <div class="page-header">

                <div>

                    <h2>Tableau de bord</h2>

                    <p>
                        Gestion de la base de données de l'hôpital
                    </p>

                </div>

                <span id="connectionStatus" class="status">
                    Vérification...
                </span>

            </div>


            <div class="cards">

                <div class="card">

                    <div class="card-icon">👤</div>

                    <span>Patients</span>

                    <strong id="countPatients">
                        0
                    </strong>

                </div>


                <div class="card">

                    <div class="card-icon">👨‍⚕️</div>

                    <span>Médecins</span>

                    <strong id="countMedecins">
                        0
                    </strong>

                </div>


                <div class="card">

                    <div class="card-icon">🏥</div>

                    <span>Admissions</span>

                    <strong id="countAdmissions">
                        0
                    </strong>

                </div>


                <div class="card">

                    <div class="card-icon">⚕️</div>

                    <span>Opérations</span>

                    <strong id="countOperations">
                        0
                    </strong>

                </div>

            </div>


            <div class="welcome">

                <h3>Bienvenue</h3>

                <p>
                    Utilisez le menu à gauche pour gérer les patients,
                    médecins, admissions, opérations et cartes RFID.
                </p>

            </div>

        </section>


        <!-- PATIENTS -->

        <section id="patients" class="page hidden">

            <div class="page-header">

                <div>

                    <h2>Patients</h2>

                    <p>Ajouter et consulter les patients</p>

                </div>

            </div>


            <form id="patientForm" class="form">

                <div class="field">

                    <label>Nom *</label>

                    <input
                        name="Nom"
                        placeholder="Nom"
                        required
                    >

                </div>


                <div class="field">

                    <label>Prénom *</label>

                    <input
                        name="Prenom"
                        placeholder="Prénom"
                        required
                    >

                </div>


                <div class="field">

                    <label>Âge</label>

                    <input
                        name="Age"
                        type="number"
                        min="0"
                        max="150"
                        placeholder="Âge"
                    >

                </div>


                <div class="field">

                    <label>Contact</label>

                    <input
                        name="Contact"
                        placeholder="Téléphone / email"
                    >

                </div>


                <div class="field">

                    <label>Groupe sanguin</label>

                    <select name="Groupe_Sanguin">

                        <option value="">
                            Sélectionner
                        </option>

                        <option value="A+">A+</option>
                        <option value="A-">A-</option>
                        <option value="B+">B+</option>
                        <option value="B-">B-</option>
                        <option value="AB+">AB+</option>
                        <option value="AB-">AB-</option>
                        <option value="O+">O+</option>
                        <option value="O-">O-</option>

                    </select>

                </div>


                <button type="submit">
                    + Ajouter le patient
                </button>

            </form>


            <div class="table-container">

                <table>

                    <thead>

                        <tr>
                            <th>ID</th>
                            <th>Nom</th>
                            <th>Prénom</th>
                            <th>Âge</th>
                            <th>Contact</th>
                            <th>Groupe</th>
                        </tr>

                    </thead>

                    <tbody id="patientsTable"></tbody>

                </table>

            </div>

        </section>


        <!-- MEDECINS -->

        <section id="medecins" class="page hidden">

            <div class="page-header">

                <div>

                    <h2>Médecins</h2>

                    <p>Ajouter et consulter les médecins</p>

                </div>

            </div>


            <form id="medecinForm" class="form">

                <div class="field">

                    <label>Nom *</label>

                    <input
                        name="Nom"
                        placeholder="Nom"
                        required
                    >

                </div>


                <div class="field">

                    <label>Prénom *</label>

                    <input
                        name="Prenom"
                        placeholder="Prénom"
                        required
                    >

                </div>


                <div class="field">

                    <label>Spécialité</label>

                    <input
                        name="Specialite"
                        placeholder="Ex : Cardiologie"
                    >

                </div>


                <div class="field">

                    <label>Contact</label>

                    <input
                        name="Contact"
                        placeholder="Téléphone / email"
                    >

                </div>


                <button type="submit">
                    + Ajouter le médecin
                </button>

            </form>


            <div class="table-container">

                <table>

                    <thead>

                        <tr>
                            <th>ID</th>
                            <th>Nom</th>
                            <th>Prénom</th>
                            <th>Spécialité</th>
                            <th>Contact</th>
                        </tr>

                    </thead>

                    <tbody id="medecinsTable"></tbody>

                </table>

            </div>

        </section>


        <!-- ADMISSIONS -->

        <section id="admissions" class="page hidden">

            <div class="page-header">

                <div>

                    <h2>Admissions</h2>

                    <p>Enregistrer les admissions des patients</p>

                </div>

            </div>


            <form id="admissionForm" class="form">

                <div class="field">

                    <label>Patient *</label>

                    <select
                        name="Id_Patient"
                        id="admissionPatient"
                        required
                    >

                        <option value="">
                            Sélectionner un patient
                        </option>

                    </select>

                </div>


                <div class="field">

                    <label>Date d'admission *</label>

                    <input
                        name="Date_Admission"
                        type="date"
                        required
                    >

                </div>


                <div class="field">

                    <label>Date de départ</label>

                    <input
                        name="Date_Depart"
                        type="date"
                    >

                </div>


                <div class="field">

                    <label>Chambre</label>

                    <input
                        name="Chambre"
                        type="number"
                        placeholder="N° chambre"
                    >

                </div>


                <div class="field field-full">

                    <label>Raison de l'admission</label>

                    <input
                        name="Raison_Admission"
                        placeholder="Raison"
                    >

                </div>


                <button type="submit">
                    + Enregistrer l'admission
                </button>

            </form>


            <div class="table-container">

                <table>

                    <thead>

                        <tr>
                            <th>ID</th>
                            <th>Patient</th>
                            <th>Admission</th>
                            <th>Départ</th>
                            <th>Raison</th>
                            <th>Chambre</th>
                        </tr>

                    </thead>

                    <tbody id="admissionsTable"></tbody>

                </table>

            </div>

        </section>


        <!-- OPERATIONS -->

        <section id="operations" class="page hidden">

            <div class="page-header">

                <div>

                    <h2>Opérations</h2>

                    <p>Enregistrer les opérations chirurgicales</p>

                </div>

            </div>


            <form id="operationForm" class="form">

                <div class="field">

                    <label>Patient *</label>

                    <select
                        name="Id_Patient"
                        id="operationPatient"
                        required
                    >

                        <option value="">
                            Sélectionner un patient
                        </option>

                    </select>

                </div>


                <div class="field">

                    <label>Médecin *</label>

                    <select
                        name="Id_Medecin"
                        id="operationMedecin"
                        required
                    >

                        <option value="">
                            Sélectionner un médecin
                        </option>

                    </select>

                </div>


                <div class="field">

                    <label>Date *</label>

                    <input
                        name="Date"
                        type="date"
                        required
                    >

                </div>


                <button type="submit">
                    + Enregistrer l'opération
                </button>

            </form>


            <div class="table-container">

                <table>

                    <thead>

                        <tr>
                            <th>ID</th>
                            <th>Patient</th>
                            <th>Médecin</th>
                            <th>Spécialité</th>
                            <th>Date</th>
                        </tr>

                    </thead>

                    <tbody id="operationsTable"></tbody>

                </table>

            </div>

        </section>


        <!-- RFID -->

        <section id="rfid" class="page hidden">

            <div class="page-header">

                <div>

                    <h2>Cartes RFID</h2>

                    <p>Gérer les cartes et leurs droits</p>

                </div>

            </div>


            <form id="rfidForm" class="form">

                <div class="field">

                    <label>ID de la carte *</label>

                    <input
                        name="id_carte"
                        placeholder="Ex : RFID001"
                        required
                    >

                </div>


                <div class="field">

                    <label>Droits</label>

                    <input
                        name="Droits"
                        placeholder="Ex : médecin"
                    >

                </div>


                <button type="submit">
                    + Ajouter la carte
                </button>

            </form>


            <div class="table-container">

                <table>

                    <thead>

                        <tr>
                            <th>ID</th>
                            <th>ID carte</th>
                            <th>Droits</th>
                        </tr>

                    </thead>

                    <tbody id="rfidTable"></tbody>

                </table>

            </div>

        </section>

    </main>

</div>


<div id="toast" class="toast"></div>


<script src="app.js"></script>

</body>

</html>
EOF

# ============================================================
# public/style.css
# ============================================================

cat > "$PROJECT/public/style.css" <<'EOF'
* {
    box-sizing: border-box;
}

:root {
    --primary: #0f3d56;
    --primary-light: #185879;
    --green: #0f766e;
    --background: #f3f6f9;
    --white: #ffffff;
    --border: #e2e8f0;
    --text: #1f2937;
    --muted: #64748b;
}

body {
    margin: 0;
    font-family:
        Inter,
        Arial,
        Helvetica,
        sans-serif;

    background: var(--background);
    color: var(--text);
}

button,
input,
select {
    font: inherit;
}

.app {
    display: flex;
    min-height: 100vh;
}

/* SIDEBAR */

.sidebar {
    width: 250px;
    min-height: 100vh;

    background: var(--primary);
    color: white;

    padding: 25px 15px;

    position: fixed;
    left: 0;
    top: 0;
    bottom: 0;
}

.sidebar h1 {
    text-align: center;
    margin: 5px 0 40px;
    font-size: 25px;
}

.sidebar nav {
    display: flex;
    flex-direction: column;
    gap: 7px;
}

.sidebar button {
    border: 0;
    background: transparent;
    color: white;

    text-align: left;

    padding: 14px 16px;

    border-radius: 8px;

    cursor: pointer;

    font-size: 15px;

    transition: .2s;
}

.sidebar button:hover {
    background: var(--primary-light);
}

/* CONTENT */

.content {
    flex: 1;
    margin-left: 250px;
    padding: 35px;
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;

    margin-bottom: 25px;
}

.page-header h2 {
    margin: 0 0 6px;
    font-size: 28px;
}

.page-header p {
    margin: 0;
    color: var(--muted);
}

.hidden {
    display: none !important;
}

/* STATUS */

.status {
    padding: 8px 14px;
    border-radius: 20px;
    background: #e2e8f0;
    color: #475569;
    font-size: 13px;
}

.status.ok {
    background: #dcfce7;
    color: #166534;
}

.status.error {
    background: #fee2e2;
    color: #991b1b;
}

/* CARDS */

.cards {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
}

.card {
    background: var(--white);

    padding: 25px;

    border-radius: 14px;

    box-shadow:
        0 2px 10px rgba(0, 0, 0, .05);
}

.card-icon {
    font-size: 28px;
    margin-bottom: 15px;
}

.card span {
    display: block;
    color: var(--muted);
    margin-bottom: 8px;
}

.card strong {
    font-size: 32px;
    color: var(--primary);
}

.welcome {
    background: white;
    border-radius: 14px;
    padding: 25px;
    margin-top: 25px;
}

.welcome h3 {
    margin-top: 0;
}

/* FORM */

.form {
    background: white;

    padding: 25px;

    border-radius: 14px;

    display: grid;

    grid-template-columns:
        repeat(2, minmax(0, 1fr));

    gap: 18px;

    margin-bottom: 25px;

    box-shadow:
        0 2px 10px rgba(0, 0, 0, .05);
}

.field {
    display: flex;
    flex-direction: column;
    gap: 7px;
}

.field-full {
    grid-column: 1 / -1;
}

.field label {
    font-size: 14px;
    font-weight: 600;
    color: #475569;
}

.form input,
.form select {
    width: 100%;

    padding: 12px 13px;

    border:
        1px solid #cbd5e1;

    border-radius: 8px;

    outline: none;

    background: white;
}

.form input:focus,
.form select:focus {
    border-color: #0f766e;

    box-shadow:
        0 0 0 3px rgba(15, 118, 110, .1);
}

.form > button {
    grid-column: 1 / -1;

    border: none;

    padding: 13px;

    border-radius: 8px;

    background: var(--green);

    color: white;

    font-weight: 600;

    cursor: pointer;
}

.form > button:hover {
    background: #0d5f59;
}

/* TABLE */

.table-container {
    background: white;

    border-radius: 14px;

    overflow-x: auto;

    box-shadow:
        0 2px 10px rgba(0, 0, 0, .05);
}

table {
    width: 100%;
    border-collapse: collapse;
}

th,
td {
    padding: 14px 16px;

    text-align: left;

    border-bottom:
        1px solid var(--border);
}

th {
    background: #eef5f8;

    color: var(--primary);

    font-size: 14px;
}

td {
    font-size: 14px;
}

tbody tr:hover {
    background: #f8fafc;
}

/* TOAST */

.toast {
    position: fixed;

    right: 25px;
    bottom: 25px;

    background: #0f3d56;

    color: white;

    padding: 14px 20px;

    border-radius: 8px;

    opacity: 0;

    transform: translateY(20px);

    pointer-events: none;

    transition: .25s;
}

.toast.show {
    opacity: 1;
    transform: translateY(0);
}

/* RESPONSIVE */

@media (max-width: 1000px) {

    .cards {
        grid-template-columns:
            repeat(2, 1fr);
    }

}

@media (max-width: 750px) {

    .sidebar {
        position: static;
        width: 100%;
        min-height: auto;
    }

    .app {
        flex-direction: column;
    }

    .content {
        margin-left: 0;
        padding: 20px;
    }

    .sidebar nav {
        display: grid;
        grid-template-columns:
            repeat(2, 1fr);
    }

    .form {
        grid-template-columns: 1fr;
    }

    .field-full {
        grid-column: auto;
    }

    .form > button {
        grid-column: auto;
    }

}

@media (max-width: 500px) {

    .cards {
        grid-template-columns: 1fr;
    }

    .page-header {
        align-items: flex-start;
        flex-direction: column;
        gap: 15px;
    }

}
EOF

# ============================================================
# public/app.js
# ============================================================

cat > "$PROJECT/public/app.js" <<'EOF'
// ============================================================
// UTILITAIRES
// ============================================================

const $ = (id) => document.getElementById(id);


function escapeHTML(value) {

    return String(value ?? "")
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;")
        .replaceAll("'", "&#039;");
}


function formatDate(value) {

    if (!value) {
        return "";
    }

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
        return value;
    }

    return date.toLocaleDateString("fr-FR");
}


function showToast(message, error = false) {

    const toast = $("toast");

    toast.textContent = message;

    toast.style.background =
        error ? "#991b1b" : "#0f3d56";

    toast.classList.add("show");

    setTimeout(() => {
        toast.classList.remove("show");
    }, 3000);
}


async function api(url, options = {}) {

    const response = await fetch(url, options);

    const data = await response.json();

    if (!response.ok) {

        throw new Error(
            data.message ||
            "Une erreur est survenue."
        );

    }

    return data;
}


// ============================================================
// NAVIGATION
// ============================================================

function showPage(pageId) {

    document
        .querySelectorAll(".page")
        .forEach(page => {
            page.classList.add("hidden");
        });

    $(pageId).classList.remove("hidden");

    if (pageId === "dashboard") {
        loadDashboard();
    }

    if (pageId === "patients") {
        loadPatients();
    }

    if (pageId === "medecins") {
        loadMedecins();
    }

    if (pageId === "admissions") {
        loadAdmissions();
    }

    if (pageId === "operations") {
        loadOperations();
    }

    if (pageId === "rfid") {
        loadRFID();
    }
}


// ============================================================
// PATIENTS
// ============================================================

async function loadPatients() {

    try {

        const patients =
            await api("/api/patients");

        $("patientsTable").innerHTML =
            patients.map(patient => `

                <tr>

                    <td>${patient.ID}</td>

                    <td>
                        ${escapeHTML(patient.Nom)}
                    </td>

                    <td>
                        ${escapeHTML(patient.Prenom)}
                    </td>

                    <td>
                        ${patient.Age ?? ""}
                    </td>

                    <td>
                        ${escapeHTML(patient.Contact)}
                    </td>

                    <td>
                        ${escapeHTML(patient.Groupe_Sanguin)}
                    </td>

                </tr>

            `).join("");

        $("countPatients").textContent =
            patients.length;

        updatePatientSelects(patients);

    } catch (error) {

        showToast(error.message, true);

    }
}


$("patientForm").addEventListener(
    "submit",
    async event => {

        event.preventDefault();

        const data =
            Object.fromEntries(
                new FormData(event.target)
            );

        try {

            await api(
                "/api/patients",
                {
                    method: "POST",

                    headers: {
                        "Content-Type":
                            "application/json"
                    },

                    body:
                        JSON.stringify(data)
                }
            );

            event.target.reset();

            showToast(
                "Patient ajouté avec succès."
            );

            await loadPatients();

            await loadDashboard();

        } catch (error) {

            showToast(
                error.message,
                true
            );

        }

    }
);


// ============================================================
// MEDECINS
// ============================================================

async function loadMedecins() {

    try {

        const medecins =
            await api("/api/medecins");

        $("medecinsTable").innerHTML =
            medecins.map(medecin => `

                <tr>

                    <td>${medecin.ID}</td>

                    <td>
                        ${escapeHTML(medecin.Nom)}
                    </td>

                    <td>
                        ${escapeHTML(medecin.Prenom)}
                    </td>

                    <td>
                        ${escapeHTML(medecin.Specialite)}
                    </td>

                    <td>
                        ${escapeHTML(medecin.Contact)}
                    </td>

                </tr>

            `).join("");

        $("countMedecins").textContent =
            medecins.length;

        updateMedecinSelects(medecins);

    } catch (error) {

        showToast(error.message, true);

    }
}


$("medecinForm").addEventListener(
    "submit",
    async event => {

        event.preventDefault();

        const data =
            Object.fromEntries(
                new FormData(event.target)
            );

        try {

            await api(
                "/api/medecins",
                {
                    method: "POST",

                    headers: {
                        "Content-Type":
                            "application/json"
                    },

                    body:
                        JSON.stringify(data)
                }
            );

            event.target.reset();

            showToast(
                "Médecin ajouté avec succès."
            );

            await loadMedecins();

            await loadDashboard();

        } catch (error) {

            showToast(
                error.message,
                true
            );

        }

    }
);


// ============================================================
// ADMISSIONS
// ============================================================

async function loadAdmissions() {

    try {

        const admissions =
            await api("/api/admissions");

        $("admissionsTable").innerHTML =
            admissions.map(admission => `

                <tr>

                    <td>
                        ${admission.ID}
                    </td>

                    <td>
                        ${escapeHTML(
                            admission.Patient
                        )}
                    </td>

                    <td>
                        ${formatDate(
                            admission.Date_Admission
                        )}
                    </td>

                    <td>
                        ${formatDate(
                            admission.Date_Depart
                        )}
                    </td>

                    <td>
                        ${escapeHTML(
                            admission.Raison_Admission
                        )}
                    </td>

                    <td>
                        ${admission.Chambre ?? ""}
                    </td>

                </tr>

            `).join("");

        $("countAdmissions").textContent =
            admissions.length;

        await loadPatients();

    } catch (error) {

        showToast(error.message, true);

    }
}


$("admissionForm").addEventListener(
    "submit",
    async event => {

        event.preventDefault();

        const data =
            Object.fromEntries(
                new FormData(event.target)
            );

        try {

            await api(
                "/api/admissions",
                {
                    method: "POST",

                    headers: {
                        "Content-Type":
                            "application/json"
                    },

                    body:
                        JSON.stringify(data)
                }
            );

            event.target.reset();

            showToast(
                "Admission enregistrée."
            );

            await loadAdmissions();

            await loadDashboard();

        } catch (error) {

            showToast(
                error.message,
                true
            );

        }

    }
);


// ============================================================
// OPERATIONS
// ============================================================

async function loadOperations() {

    try {

        const operations =
            await api("/api/operations");

        $("operationsTable").innerHTML =
            operations.map(operation => `

                <tr>

                    <td>
                        ${operation.ID}
                    </td>

                    <td>
                        ${escapeHTML(
                            operation.Patient
                        )}
                    </td>

                    <td>
                        ${escapeHTML(
                            operation.Medecin
                        )}
                    </td>

                    <td>
                        ${escapeHTML(
                            operation.Specialite
                        )}
                    </td>

                    <td>
                        ${formatDate(
                            operation.Date
                        )}
                    </td>

                </tr>

            `).join("");

        $("countOperations").textContent =
            operations.length;

        await loadPatients();

        await loadMedecins();

    } catch (error) {

        showToast(error.message, true);

    }
}


$("operationForm").addEventListener(
    "submit",
    async event => {

        event.preventDefault();

        const data =
            Object.fromEntries(
                new FormData(event.target)
            );

        try {

            await api(
                "/api/operations",
                {
                    method: "POST",

                    headers: {
                        "Content-Type":
                            "application/json"
                    },

                    body:
                        JSON.stringify(data)
                }
            );

            event.target.reset();

            showToast(
                "Opération enregistrée."
            );

            await loadOperations();

            await loadDashboard();

        } catch (error) {

            showToast(
                error.message,
                true
            );

        }

    }
);


// ============================================================
// RFID
// ============================================================

async function loadRFID() {

    try {

        const cards =
            await api("/api/rfid");

        $("rfidTable").innerHTML =
            cards.map(card => `

                <tr>

                    <td>
                        ${card.ID}
                    </td>

                    <td>
                        ${escapeHTML(
                            card.id_carte
                        )}
                    </td>

                    <td>
                        ${escapeHTML(
                            card.Droits
                        )}
                    </td>

                </tr>

            `).join("");

    } catch (error) {

        showToast(error.message, true);

    }
}


$("rfidForm").addEventListener(
    "submit",
    async event => {

        event.preventDefault();

        const data =
            Object.fromEntries(
                new FormData(event.target)
            );

        try {

            await api(
                "/api/rfid",
                {
                    method: "POST",

                    headers: {
                        "Content-Type":
                            "application/json"
                    },

                    body:
                        JSON.stringify(data)
                }
            );

            event.target.reset();

            showToast(
                "Carte RFID ajoutée."
            );

            await loadRFID();

        } catch (error) {

            showToast(
                error.message,
                true
            );

        }

    }
);


// ============================================================
// LISTES DEROULANTES
// ============================================================

function updatePatientSelects(patients) {

    const selects = [
        $("admissionPatient"),
        $("operationPatient")
    ];

    selects.forEach(select => {

        const selected =
            select.value;

        select.innerHTML =
            `<option value="">
                Sélectionner un patient
            </option>`;

        patients.forEach(patient => {

            const option =
                document.createElement("option");

            option.value =
                patient.ID;

            option.textContent =
                `${patient.Prenom || ""}
                 ${patient.Nom || ""}
                 — ID ${patient.ID}`;

            select.appendChild(option);

        });

        select.value = selected;

    });
}


function updateMedecinSelects(medecins) {

    const select =
        $("operationMedecin");

    const selected =
        select.value;

    select.innerHTML =
        `<option value="">
            Sélectionner un médecin
        </option>`;

    medecins.forEach(medecin => {

        const option =
            document.createElement("option");

        option.value =
            medecin.ID;

        option.textContent =
            `${medecin.Prenom || ""}
             ${medecin.Nom || ""}
             — ${medecin.Specialite || ""}`;

        select.appendChild(option);

    });

    select.value = selected;
}


// ============================================================
// DASHBOARD
// ============================================================

async function loadDashboard() {

    try {

        const [
            patients,
            medecins,
            admissions,
            operations
        ] = await Promise.all([

            api("/api/patients"),

            api("/api/medecins"),

            api("/api/admissions"),

            api("/api/operations")

        ]);

        $("countPatients").textContent =
            patients.length;

        $("countMedecins").textContent =
            medecins.length;

        $("countAdmissions").textContent =
            admissions.length;

        $("countOperations").textContent =
            operations.length;

        updatePatientSelects(patients);

        updateMedecinSelects(medecins);

    } catch (error) {

        showToast(error.message, true);

    }
}


// ============================================================
// TEST CONNEXION
// ============================================================

async function testConnection() {

    try {

        await api("/api/test");

        const status =
            $("connectionStatus");

        status.textContent =
            "● MariaDB connectée";

        status.classList.add("ok");

    } catch (error) {

        const status =
            $("connectionStatus");

        status.textContent =
            "● MariaDB déconnectée";

        status.classList.add("error");

    }
}


// ============================================================
// DEMARRAGE
// ============================================================

testConnection();

showPage("dashboard");
EOF

