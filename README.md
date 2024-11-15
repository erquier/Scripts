Active Directory Automation Scripts
Este repositorio contiene una colección de scripts y herramientas en PowerShell y Batch diseñadas para facilitar la administración de Active Directory (AD). Los scripts están organizados en carpetas según sus funcionalidades y pueden ser utilizados para automatizar tareas comunes en entornos de TI, como la gestión de usuarios, restricciones de red y búsquedas en el directorio. Cada script ha sido optimizado para mejorar la eficiencia en la gestión de AD, incluyendo barras de progreso, manejo de errores, y mensajes claros para el usuario.

Estructura del Repositorio
Network_Restrictions: Scripts para gestionar y aplicar restricciones de red a usuarios específicos en el AD.

New_Hire: Automatización de tareas para la incorporación de nuevos empleados, incluyendo la creación de cuentas y configuración inicial.

Ou_Search: Herramientas para buscar y listar información de unidades organizativas (OUs) en el AD.

Unlock_AD_Account: Scripts para desbloquear cuentas de usuarios en el AD de forma rápida.

UsernameLookup: Herramientas para buscar información de usuarios en el AD utilizando nombres de usuario.

passwordChange: Scripts para gestionar y forzar cambios de contraseña de usuarios en el AD.

Scripts Independientes
Add-User-To-AD-Group.ps1: Script para agregar usuarios a un grupo de seguridad en AD. Incluye verificación de usuarios, barra de progreso, y un resumen final con los resultados.

AsignarUsuariosDeOUaGrupo.bat / AsignarUsuariosDeOUaGrupo.ps1: Scripts en Batch y PowerShell para asignar usuarios de una unidad organizativa específica a un grupo de AD.

ChangeUPN.ps1: Permite cambiar el User Principal Name (UPN) de los usuarios en AD, útil para migraciones o actualizaciones de políticas.

LockedSourceAccount.ps1: Script para listar cuentas bloqueadas y gestionar el desbloqueo de cuentas en AD.

OU Search Test.ps1: Herramienta para buscar OUs específicas en AD y realizar pruebas sobre sus configuraciones y estructuras.

Requisitos
PowerShell: La mayoría de los scripts están en PowerShell, por lo que es necesario tener PowerShell instalado y configurado en tu sistema.
Módulo de Active Directory: Algunos scripts requieren el módulo de Active Directory para ejecutar cmdlets como Get-ADUser, Add-ADGroupMember, entre otros.
Cómo Usar
Clona el repositorio: git clone https://github.com/erquier/Scripts.git
Navega al directorio correspondiente al script que deseas utilizar.
Lee las instrucciones dentro de cada script para adaptarlo a tus necesidades específicas antes de ejecutarlo.
Contribuciones
Si deseas contribuir con mejoras o nuevos scripts, por favor haz un fork de este repositorio y crea un pull request con tus cambios. Asegúrate de seguir el formato y la estructura de los scripts existentes.

Notas
Estos scripts fueron creados y optimizados para mejorar la administración de AD y hacer más eficientes las tareas diarias en entornos empresariales. Asegúrate de probar cada script en un entorno de prueba antes de aplicarlos en producción.
