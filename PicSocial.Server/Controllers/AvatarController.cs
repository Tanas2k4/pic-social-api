using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs.AvatarsDto;
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

        /// <summary>
        /// Upload or update user avatar.
        /// </summary>
        /// <remarks>
        /// Uploads a new avatar image for the currently authenticated user.
        /// The image must be sent as multipart/form-data.
        /// </remarks>
        /// <param name="avatar">Avatar image file</param>
        /// <response code="200">Avatar uploaded successfully</response>
        /// <response code="400">No file uploaded</response>
        /// <response code="401">Unauthorized</response>
        [HttpPost]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadAvatar(
            [FromForm] AvatarUploadDto avatar)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _avatarService.UploadAvatarAsync(
                currentUser.Id,
                avatar.Avatar!
            );

            return StatusCode(result.StatusCode, new { message = result.Message });
        }

        /// <summary>
        /// Delete current user's avatar.
        /// </summary>
        /// <remarks>
        /// Removes the avatar image of the currently authenticated user.
        /// </remarks>
        /// <response code="200">Avatar deleted successfully</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="404">No avatar to delete</response>
        [HttpDelete]
        public async Task<IActionResult> DeleteAvatar()
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _avatarService.DeleteAvatarAsync(currentUser.Id);
            return StatusCode(result.StatusCode, new { message = result.Message });
        }
    }
}