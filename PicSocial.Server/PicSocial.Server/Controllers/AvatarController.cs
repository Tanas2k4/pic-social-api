using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.Models;
using PicSocial.Server.Services;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class AvatarController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly GoogleCloudStorageService _googleCloudStorageService;

        public AvatarController(GoogleCloudStorageService googleCloudStorageService, UserManager<ApplicationUser> userManager)
        {
            _userManager = userManager;
            _googleCloudStorageService = googleCloudStorageService;
        }

        // POST api/avatar/upload
        [HttpPost("upload")]
        public async Task<IActionResult> UploadAvatar([FromForm] IFormFile avatar)
        {
            //Kiểm tra chính chủ
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            //Kiểm tra file được tải lên
            if (avatar == null)
                return BadRequest("No file uploaded");

            //Xóa và ghì đè avatar mới 
            if (!string.IsNullOrEmpty(user.AvatarUrl))
            {
                var oldAvatar = Path.GetFileName(user.AvatarUrl);
                await _googleCloudStorageService.DeleteFileAsync($"avatars/{oldAvatar}");
            }

            var objectName = $"avatars/{Guid.NewGuid()}{Path.GetExtension(avatar.FileName)}";
            var fileUrl = await _googleCloudStorageService.UploadFileAsync(
                avatar.OpenReadStream(),
                objectName,
                avatar.ContentType
            );

            user.AvatarUrl = objectName;
            user.AvatarUrl = fileUrl;
            await _userManager.UpdateAsync(user);

            return Ok(new { message = "upload completed" });
        }

        // DELETE api/avatar/delete
        [HttpDelete("delete")]
        public async Task<IActionResult> DeleteAvatar()
        {
            //Kiểm tra chính chủ
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            if (string.IsNullOrEmpty(user.AvatarUrl))
                return BadRequest("No avatar here!!");

            //Kiểm tra file
            var objectName = user.AvatarUrl.Split("/").Last();
            await _googleCloudStorageService.DeleteFileAsync($"avatars/{objectName}");

            user.AvatarUrl = null; //thay vì null thì có thể set avatar về mặc định 
            await _userManager.UpdateAsync(user);
            return Ok(new { message = "delete complete" });
        }
    }
}