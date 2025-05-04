# Aplicación Guía Turística
Apliación de Flutter que permite guardar lugares turísticos de Quito y escribir reseñas de ellos.

## Empezar
Descargar el .zip y dentro del proyecto ejecutar
flutter pub get
Para descargar las librerías necesarias.

Se posee un backend con docker para levantar un servidor con node y conectarse al motor de base de datos posrtgres. 

Para ello dentro de la carpeta raíz renombrar el archivo llamado ".env copy" a ".env" con las credenciales que requieran, del proyecto ejecutar. Se recomienda no cambiar la variable POSTGRES_HOST, debido a que con ella esta configurado el Dockerfile, lo demás colocar las credenciales respectivas.

ES NECESARIO CORRER EL COMANDO DE DOCKER PARA INTERACTUAR CON LA BASE DE DATOS, SI SE REQUIERE HACER CAMBIOS EN LA CARPETA BACKEND.

## Estructura
La estructura del proyecto consta de un backend y la aplicación de Flutter.

Las carpetas para el desarrollo son
-backend
-lib

Dentro del lib se encuentra la carpeta features, en ella se encuentran las screens o pantallas de la aplicación.

--auth pantalla para la authenticación y el login
--home pantalla donde se despliegan las opcionse de perfil, mapa y lugares.
--map pantalla del mapa interactivo
--poi pantalla para los lugares turísticos y las reseñas.
--profile perfil del usuario loggeado


