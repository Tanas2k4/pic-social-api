using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs.CoverPhotosDto;
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

        /// <summary>
        /// Uploads or replaces the current user's cover photo.
        /// </summary>
        /// <param name="coverPhoto">Form data containing the cover photo file (field name: coverPhoto).</param>
        /// <returns>
        /// 200 OK: Simple object with success message.<br/>
        /// 400 Bad Request: If no file is provided.<br/>
        /// 401 Unauthorized: If user is not authenticated or not found.
        /// </returns>
        /// <response code="200">cover photo uploaded</response>
        /// <response code="400">not found (no file uploaded)</response>
        /// <response code="401">User not found or unauthorized</response>
        [HttpPost]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadPhotoCover(
            [FromForm] CoverPhotoUploadDto coverPhoto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _coverPhotoService.UploadPhotoCoverAsync(
                currentUser.Id,
                coverPhoto.coverPhoto!
            );

            return StatusCode(result.StatusCode, new { message = result.Message });
        }

        /// <summary>
        /// Deletes the current user's cover photo, if one exists.
        /// </summary>
        /// <returns>
        /// 200 OK: Simple object with success message.<br/>
        /// 400 Bad Request: If the user has no cover photo to delete.<br/>
        /// 401 Unauthorized: If user is not authenticated or not found.
        /// </returns>
        /// <response code="200">Cover photo deleted successfully</response>
        /// <response code="400">No cover photo to delete</response>
        /// <response code="401">User not found or unauthorized</response>
        [HttpDelete]
        public async Task<IActionResult> DeletePhotoCover()
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _coverPhotoService.DeletePhotoCoverAsync(currentUser.Id);

            return StatusCode(result.StatusCode, new { message = result.Message });
        }
    }
}