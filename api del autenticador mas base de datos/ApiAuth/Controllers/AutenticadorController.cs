using ApiAuth.Context;
using ApiAuth.Modelos;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OtpNet;

namespace ApiAuth.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AutenticadorController : ControllerBase
    {
        private readonly DBAutenticadorContext _context;

        public AutenticadorController(DBAutenticadorContext context)
        {
            _context = context;
        }

        [HttpPost("generate-code")]
        public IActionResult GenerateCode([FromBody] TOTPRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.SecretKey))
            {
                return BadRequest("La clave secreta es obligatoria.");
            }

            try
            {
                // Convertir la clave secreta de Base32 a bytes
                var secretKeyBytes = Base32Encoding.ToBytes(request.SecretKey);

                // Crear una instancia de Totp con el algoritmo SHA-1 y un intervalo de 30 segundos
                var totp = new Totp(secretKeyBytes, mode: OtpHashMode.Sha1, step: 30);

                // Generar el código TOTP
                var code = totp.ComputeTotp(DateTime.UtcNow);

                return Ok(new { Code = code });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Error = "Error al generar el código", Details = ex.Message });
            }
        }


        [HttpPost("insertarNuevoTotp/{codUsuario}")]
        public IActionResult insertarNuevoTotp(int codUsuario, [FromBody] TOTPRequest request)
        {
            try
            {
                // Validación de entrada
                if (string.IsNullOrWhiteSpace(request.SecretKey))
                {
                    return BadRequest("La clave secreta es obligatoria.");
                }

                // Crear una nueva instancia del modelo
                var nuevoCuentaAutenticador = new cat_cuentas_autenticador_totp
                {
                    cat_codper = codUsuario,
                    cat_cuenta = request.Account,
                    cat_clave = request.SecretKey
                };

                // Agregar a la base de datos
                _context.cat_cuentas_autenticador_totps.Add(nuevoCuentaAutenticador);
                _context.SaveChanges();

                return Ok("Usuario insertado correctamente.");
            }
            catch (Exception ex)
            {
                // Manejar errores y devolver una respuesta HTTP 500
                return StatusCode(500, $"Ocurrió un error inesperado: {ex.Message}");
            }
        }




        [HttpGet("obtenerDatos/{codusr}")]
        public async Task<ActionResult<cat_cuentas_autenticador_totp>> obtenerDatos(int codusr)
        {
            try
            {
                var usuario = await _context.cat_cuentas_autenticador_totps.Where(x => x.cat_codper == codusr).ToListAsync();

                if (!usuario.Any())
                {
                    return NotFound("Usuario no encontrado"); 
                }

                return Ok(usuario); 
            }
            catch (Exception ex)
            {
                return BadRequest($"Error: {ex.Message}");
            }
        }

        [HttpGet("obtenerUsuario/{usuario}/{clave}")]
        public async Task<ActionResult<usr_usuario>> obtenerDatos(string usuario, string clave)
        {
            try
            {
                var estudiante = await _context.usr_usuarios.Where(x => x.usr_usuario1 == usuario && x.usr_password == clave).ToListAsync();

                if (!estudiante.Any())
                {
                    return NotFound("Usuario no encontrado");
                }

                return Ok(estudiante);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error: {ex.Message}");
            }
        }

        [HttpDelete("eliminarTotp/{codCat}")]
        public async Task<IActionResult> EliminarTotp(int codCat)
        {
            try
            {
                // Buscar el registro con el código proporcionado
                var totp = await _context.cat_cuentas_autenticador_totps.Where(c => c.cat_codigo == codCat).FirstOrDefaultAsync();

                // Validar si el registro existe
                if (totp == null)
                {
                    return NotFound($"No se encontró un registro con el código {codCat}.");
                }

                // Eliminar el registro de la base de datos
                _context.cat_cuentas_autenticador_totps.Remove(totp);
                await _context.SaveChangesAsync();

                return Ok($"El registro con el código {codCat} fue eliminado correctamente.");
            }
            catch (Exception ex)
            {
                // Manejar errores y devolver una respuesta HTTP 500
                return StatusCode(500, $"Ocurrió un error inesperado: {ex.Message}");
            }
        }




    }

    public class TOTPRequest
    {
        public string? Account { get; set; }
        public string? SecretKey { get; set; }
    }
}
