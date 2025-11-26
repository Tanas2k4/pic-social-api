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
    public class AvatarController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IAvatarService _avatarService;

        public AvatarController(UserManager<ApplicationUser> userManager, IAvatarService avatarService)
        {
            _userManager = userManager;
            _avatarService = avatarService;
        }

        // POST api/avatar
        [HttpPost]
        public async Task<IActionResult> UploadAvatar([FromForm] IFormFile avatar)
        {
            //Kiểm tra chính chủ
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _avatarService.UploadAvatarAsync(currentUser.Id, avatar);
            return StatusCode(result.StatusCode, new { message = result.Message});
        }

        // DELETE api/avatar
        [HttpDelete]
        public async Task<IActionResult> DeleteAvatar()
        {
            //Kiểm tra chính chủ
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _avatarService.DeleteAvatarAsync(currentUser.Id);
            return StatusCode(result.StatusCode, new { message = result.Message});
        }
    }
}