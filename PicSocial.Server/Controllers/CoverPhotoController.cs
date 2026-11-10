using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs.CoverPhotosDto;
using PicSocial.Server.Extensions;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CoverPhotoController : ControllerBase
    {
        private readonly ICoverPhotoService _coverPhotoService;

        public CoverPhotoController(ICoverPhotoService coverPhotoService)
        {
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
            var currentUserId = User.GetUserId();
            if (string.IsNullOrEmpty(currentUserId))
                return Unauthorized();

            var result = await _coverPhotoService.UploadPhotoCoverAsync(
                currentUserId,
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
            var currentUserId = User.GetUserId();
            if (string.IsNullOrEmpty(currentUserId))
                return Unauthorized();

            var result = await _coverPhotoService.DeletePhotoCoverAsync(currentUserId);

            return StatusCode(result.StatusCode, new { message = result.Message });
        }
    }
}