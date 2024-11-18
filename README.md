

# **BankingMicroservice**

## **Overview**

The **BankingMicroservice** is a Maven-based Java microservice designed to handle core banking operations such as account management, transaction processing, and customer data handling. It is built using **Spring Boot** for rapid development and scalability. The project also includes infrastructure automation with **Ansible** and containerization using **Docker**.

This repository demonstrates modern software development practices, including:
- Automated build pipelines.
- Unit testing.
- Production server configuration.

---

## **Features**

### **Application Features**
- **Account Management**: Create, update, and delete accounts.
- **Transaction Processing**: Securely handle deposits, withdrawals, and transfers.
- **RESTful APIs**: Provide seamless interaction with other services or clients.
- **Unit Testing**: Comprehensive tests using **JUnit 5**.
- **Build Automation**: Simplified dependency management and builds using Maven.

### **Infrastructure Features**
- **Ansible Automation**: Install and configure software on production servers.
- **Dockerized Deployment**: Run the microservice in lightweight, portable containers.

---

## **Getting Started**

### **Prerequisites**

Make sure the following tools are installed on your system:
- **Java**: Version 11 or higher.
- **Maven**: Build automation tool.
- **Docker** and **Docker Compose**: For containerized deployment.
- **Ansible**: For server setup and configuration.
- **Git**: For version control.

### **Clone the Repository**

```bash
git clone git@github.com:Abhiram1227/BankingMicroservice.git
cd BankingMicroservice
```

---

## **Building the Application**

### **Using Maven**
1. Navigate to the project directory:
   ```bash
   cd BankingMicroservice
   ```
2. Build the project:
   ```bash
   mvn clean install
   ```
3. The compiled JAR file will be located in the `target` directory:
   ```bash
   target/BankingMicroservice-1.0-SNAPSHOT.jar
   ```

---

## **Running the Application**

### **Running Locally**
Start the microservice using the JAR file:
```bash
java -jar target/BankingMicroservice-1.0-SNAPSHOT.jar
```
The service will be accessible at: `http://localhost:8080`.

---

## **Deployment**

### **Using Ansible**

1. **Prepare Environment**:
   - Set up two VMs: 
     - An **Ansible Controller**.
     - An **Ansible Client**.
   - Configure SSH keys for passwordless login:
     ```bash
     ssh-keygen
     ssh-copy-id user@<client-ip>
     ```
   - Verify connectivity:
     ```bash
     ansible all -m ping
     ```

2. **Install Java and Apache on the Client**:
   Run the playbook:
   ```bash
   ansible-playbook install_java_apache.yml
   ```

3. **Install Docker on the Controller**:
   Use another playbook to set up Docker:
   ```bash
   ansible-playbook install_docker.yml
   ```

---

### **Using Docker**

1. **Build the Docker Image**:
   ```bash
   docker build -t banking-microservice:1.0 .
   ```
2. **Run the Docker Container**:
   ```bash
   docker run -d -p 8080:8080 banking-microservice:1.0
   ```
3. Access the service at: `http://localhost:8080`.

---

## **API Endpoints**

| **Endpoint**         | **Method** | **Description**            |
|----------------------|------------|----------------------------|
| `/accounts`          | GET        | Retrieve all accounts      |
| `/accounts/{id}`     | GET        | Retrieve account by ID     |
| `/accounts`          | POST       | Create a new account       |
| `/transactions`      | POST       | Process a transaction      |
| `/customers`         | GET        | Retrieve all customers     |

---

## **Testing**

Run unit tests using Maven:
```bash
mvn test
```
Test cases are located in the `src/test/` directory.

---

## **Branch Management**

- **Branch Strategy**:
  - Two branches (`b1` and `b2`) are created for development.
  - Each branch is assigned to a developer.
- **Workflow**:
  - Code changes are reviewed and merged into the **main** branch after approval.

---

## **Project Structure**

```
BankingMicroservice/
│
├── src/
│   ├── main/
│   │   ├── java/com/bank/
│   │   │   ├── controller/
│   │   │   ├── service/
│   │   │   ├── model/
│   │   │   └── repository/
│   │   ├── resources/
│   │       └── application.properties
│   └── test/
│       ├── java/com/bank/
│       └── resources/
├── target/
├── Dockerfile
├── install_java_apache.yml
├── pom.xml
└── README.md
```

---

## **Contributing**

1. Fork the repository.
2. Create a new branch for your feature:
   ```bash
   git checkout -b feature-name
   ```
3. Make your changes and commit them:
   ```bash
   git commit -m "Add new feature"
   ```
4. Push the branch to your fork:
   ```bash
   git push origin feature-name
   ```
5. Open a pull request on GitHub.

---



---

## **Contact**

For any questions or support, please contact:
- **GitHub**: [Abhiram1227](https://github.com/Abhiram1227)

---

