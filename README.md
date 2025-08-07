# Animalshelter
<div align="center">
  <img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/logo.png" alt="Logo" width="400"/>
</div>

## Concept
AnimalShelter is a web application developed in Elixir and Phoenix to manage animal adoption requests. The platform allows users to view animals available for adoption, submit adoption requests, and for administrators to manage animals and adoption processes. The goal is to streamline the adoption workflow and provide a transparent, interactive experience for both adopters and administrators.

## Features
- User Registration and Authentication
  - Register new users with email and username validation.
  - Login and logout functionality.
- Animal Management
  - View a list of animals available for adoption.
  - Submit adoption requests with comments for each animal (one request per user per animal).
  - Admin panel for creating, editing, and deleting animal records.
  - Admin panel for selecting the winning adoption request for each animal.
- User Dashboard
  - View and edit user profile.
  - View history of adoption requests.
- Admin Dashboard
  - Access restricted to admins.
  - Manage users and animals.

## Technical Documentation

### Technologies and Languages Used
- **Elixir**: A concurrent functional language used for business logic and backend.
- **Phoenix Framework**: A web framework for Elixir, used to build the web application, APIs, and LiveView components.
- **Ecto**: An Elixir library for object-relational mapping (ORM) and database migrations.
- **PostgreSQL**: A relational database management system.
- **Tailwind CSS**: A utility-first CSS framework used for frontend styling.
- **JavaScript**: Used for interactive frontend functionality.
- **Docker**: Used for deployment and local development, simplifying dependency and service management.

### Project Structure
- `animalshelter/lib/animalshelter_web/`: Main web code, layouts, components, LiveViews, controllers.
- `animalshelter/lib/animalshelter/accounts/user.ex`: User model and logic.
- `animalshelter/lib/animalshelter/animals/`: Animal model and adoption logic.
- `animalshelter/assets/`: Static files (JS, CSS, images).
- `animalshelter/config/`: Environment configurations.
- `animalshelter/test/`: Automated tests.
- `docker-compose.yml`: Service configuration for development and deployment.

### Main Modules and Components
- `Animalshelter.Accounts.User`: Ecto model for users, including validations, registration, authentication, and roles.
- `Animalshelter.Animals.Animal`: Ecto model for animals and adoption request logic.
- Layouts and Components: `root.html.heex` (main layout), `app.html.heex` (secondary layout).
- LiveViews and Controllers: Handle animals, users, and administration.

### Security
- User authentication using Bcrypt.
- Email validation.
- User roles (admin, regular user).

## Installation Guide (Linux)

### Prerequisites
Make sure you have the following installed:
- Docker & Docker Compose
- Elixir
- Mix (comes with Elixir)
- Erlang (required by Elixir)

### Installation Steps
- Update your package list: `sudo apt-get update`
- Install file watching tools (required for live reload in some setups): `sudo apt-get install inotify-tools`
- Start Docker containers in the background: `docker compose up -d`
- Navigate to the project directory: `cd animalshelter`
- Create the database: `mix ecto.create`
- Start the Phoenix server: `mix phx.server`
- The application should now be running at: http://localhost:4000
- To stop and remove the Docker containers: `docker compose down`

## Screens
Home when user is not authenticated

<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/home-not-authenticated.png" alt="Home when user is not authenticated" width="700"/>

Home when user is authenticated
  
<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/home-user-authenticated.png" alt="Home when user is authenticated" width="700"/>

Home when admin is authenticated
  
<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/home-admin-authenticated.png" alt="Home when admin is authenticated" width="700"/>

Adopted animal view when user is not authenticated

<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/animal-adopted-user-not-authenticated.png" alt="Adopted animal view when user is not authenticated" width="700"/>

Not adopted animal view when user is not authenticated

<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/animal-not-adopted-user-not-authenticated.png" alt="Not adopted animal view when user is not authenticated" width="700"/>

Not adopted animal view when user is authenticated

<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/animal-not-adopted-user-authenticated.png" alt="Not adopted animal view when user is authenticated" width="700"/>

Not adopted animal view when user is authenticated and has already requested

<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/animal-not-adopted-already-requested-user-authenticated.png" alt="Not adopted animal view when user is authenticated and has already requested" width="700"/>

Login

<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/login.png" alt="Login" width="700"/>

Register

<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/register.png" alt="Register" width="700"/>

User settings

<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/user-settings.png" alt="User settings" width="700"/>

Admin animals

<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/admin-animals.png" alt="Admin animals" width="700"/>

New animal

<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/new-animal.png" alt="New animal" width="700"/>

Edit animal

<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/edit-animal.png" alt="Edit animal" width="700"/>

Select adoptive user for animal

<img src="https://github.com/jj-tena/AnimalShelter/blob/main/images/select-adoptive-user-for-animal.png" alt="Edit animal" width="700"/>
