using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.Models;
using PicSocial.Server.Services;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CoverPhotoController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly GoogleCloudStorageService _googleCloudStorageService;
    
        public CoverPhotoController(UserManager<ApplicationUser> userManager, GoogleCloudStorageService googleCloudStorageService)
        {
            _userManager = userManager;
            _googleCloudStorageService = googleCloudStorageService;
        }

        //POST api/coverPhoto/upload
        [HttpPost("upload")]
        public async Task<IActionResult> UploadPhotoCover([FromForm] IFormFile photoCover)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            //Kiểm tra file
            if (photoCover == null)
            {
                return BadRequest("not found");
            }

            //ghì đè nếu có ảnh bìa cũ 
            if (!string.IsNullOrEmpty(user.CoverPhotoUrl))
            {
                var oldCoverPhoto = Path.GetFileName(user.CoverPhotoUrl);
                await _googleCloudStorageService.DeleteFileAsync($"coverPhotos/{oldCoverPhoto}");
            }

            var objectName = $"coverPhotos/{Guid.NewGuid()}{Path.GetExtension(photoCover.FileName)}";
            var fileUrl = await _googleCloudStorageService.UploadFileAsync(
                photoCover.OpenReadStream(),
                objectName,
                photoCover.ContentType
            );

            user.CoverPhotoUrl = fileUrl;
            await _userManager.UpdateAsync(user);

            return Ok(new { message = "cover photo uploaded" });
        }
    }
}