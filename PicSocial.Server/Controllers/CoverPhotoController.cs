using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CoverPhotoController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ICoverPhotoService _coverPhotoService;

        public CoverPhotoController(UserManager<ApplicationUser> userManager, ICoverPhotoService coverPhotoService)
        {
            _userManager = userManager;
            _coverPhotoService = coverPhotoService;
        }

        //POST api/coverPhoto
        [HttpPost]
        public async Task<IActionResult> UploadPhotoCover([FromForm] IFormFile photoCover)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _coverPhotoService.UploadPhotoCoverAsync(currentUser.Id, photoCover);
            return StatusCode(result.StatusCode, new { message = result.Message});
        }

        //DELETE api/coverPhoto
        [HttpDelete]
        public async Task<IActionResult> DeletePhotoCover()
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _coverPhotoService.DeletePhotoCoverAsync(currentUser.Id);
            return StatusCode(result.StatusCode, new { message = result.Message});
        }
    }
}