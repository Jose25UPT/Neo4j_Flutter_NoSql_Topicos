// Importar librerías necesarias
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const neo4j = require('neo4j-driver');

// Inicializar la aplicación y puerto
const app = express();
const port = 3000;

// Configurar middlewares
app.use(cors());
app.use(bodyParser.json());

// Conectar a Neo4j
const driver = neo4j.driver(
  'neo4j://localhost:7687',
  neo4j.auth.basic('neo4j', 'contraseña_correcta') // Reemplaza con la contraseña correcta
);

// Ruta principal de prueba
app.get('/', (req, res) => {
  res.send('¡Hola, mundo! Este es el backend para Neo4j.');
});

// Ruta para obtener nodos
app.get('/nodes', async (req, res) => {
  const session = driver.session();
  try {
    const result = await session.run('MATCH (n) RETURN n LIMIT 25');
    const nodes = result.records.map(record => record.get('n').properties);
    res.json(nodes);
  } catch (error) {
    console.error('Error al ejecutar la consulta en Neo4j:', error);
    res.status(500).send('Error al obtener los nodos');
  } finally {
    await session.close();
  }
});

// Ruta para crear un nuevo nodo
app.post('/nodes', async (req, res) => {
  const session = driver.session();
  const { name, type, description } = req.body; // Espera que el cuerpo tenga estos campos

  try {
    const result = await session.run(
      'CREATE (n:Node {name: $name, type: $type, description: $description}) RETURN n',
      { name, type, description }
    );

    const createdNode = result.records[0].get('n').properties;
    res.status(201).json(createdNode);
  } catch (error) {
    console.error('Error al crear el nodo:', error);
    res.status(500).send('Error al crear el nodo');
  } finally {
    await session.close();
  }
});

// Iniciar el servidor
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
