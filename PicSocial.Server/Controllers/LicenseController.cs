using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class LicenseController : ControllerBase
    {
        private readonly ILicenseService _licenseService;
        public LicenseController(ILicenseService licenseService)
        {
            _licenseService = licenseService;
        }

        // GET api/license Get all licenses
        [HttpGet]
        public async Task<IActionResult> GetAllLicenses()
        {
            var result = await _licenseService.GetAllLicensesAsync();
            if (result == null || !result.Any())
            {
                return NotFound(new { messsage = "No licenses found." });
            }
            return Ok(result);
        }
    }
}
