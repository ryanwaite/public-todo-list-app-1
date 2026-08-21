extension radius

param environment string

@secure()
param mysqlPassword string

resource publicTodoListApp1App 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'public-todo-list-app-1'
  properties: {
    environment: environment
  }
}

resource mysqlDb 'Radius.Data/mySqlDatabases@2025-08-01-preview' = {
  name: 'mysql'
  properties: {
    environment: environment
    application: publicTodoListApp1App.id
    codeReference: 'src/persistence/mysql.js#L31'
    username: 'myadmin'
    password: mysqlPassword
    database: 'todos'
    version: '8.0'
  }
}

resource publicTodoListApp1Image 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'public-todo-list-app-1-image'
  properties: {
    environment: environment
    application: publicTodoListApp1App.id
    codeReference: 'Dockerfile'
    build: {
      source: 'git::https://github.com/ryanwaite/public-todo-list-app-1.git?ref=ddce5894d9694fe034dff00c3427f9878a35044d'
      platforms: [
        'linux/amd64'
      ]
    }
  }
}

resource publicTodoListApp1Container 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'public-todo-list-app-1'
  properties: {
    environment: environment
    application: publicTodoListApp1App.id
    codeReference: 'src/index.js#L17'
    containers: {
      publicTodoListApp1: {
        image: publicTodoListApp1Image.properties.imageReference
        ports: {
          web: {
            containerPort: 3000
          }
        }
        env: {
          MYSQL_HOST: {
            value: mysqlDb.properties.host
          }
          MYSQL_USER: {
            value: 'myadmin'
          }
          MYSQL_PASSWORD: {
            value: mysqlPassword
          }
          MYSQL_DB: {
            value: 'todos'
          }
        }
      }
    }
  }
}
