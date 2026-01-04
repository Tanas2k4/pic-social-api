using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs.PhotosDto;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PhotoController : ControllerBase
    {
        private readonly IPhotoService _photoService;
        private readonly UserManager<ApplicationUser> _userManager;

        public PhotoController(IPhotoService photoService, UserManager<ApplicationUser> userManager)
        {
            _photoService = photoService;
            _userManager = userManager;
        }

        /// <summary>
        /// Updates settings for a specific photo (public visibility and download permission).
        /// Only the owner of the photo can perform this action.
        /// </summary>
        /// <param name="photoId">The ID of the photo to update.</param>
        /// <param name="dto">Contains optional IsPublic and AllowDownload flags to update.</param>
        /// <returns>
        /// 200 OK: Simple object with success message.<br/>
        /// 401 Unauthorized: If user is not authenticated or not found.<br/>
        /// 404 Not Found: If the photo does not exist.
        /// </returns>
        /// <response code="200">update successfully</response>
        /// <response code="401">User not found</response>
        /// <response code="404">Not found</response>
        [HttpPatch("{photoId}")]
        public async Task<IActionResult> UpdatePhoto(Guid photoId, [FromBody] PhotoUpdateDto dto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _photoService.UpdatePhotoAsync(photoId, currentUser.Id, dto);
            return StatusCode(result.StatusCode, new { message = result.Message });
        }

        /// <summary>
        /// Retrieves detailed information about a specific photo belonging to a user.
        /// </summary>
        /// <param name="photoId">The ID of the photo.</param>
        /// <param name="userId">The ID of the user who owns the photo (query parameter).</param>
        /// <returns>
        /// 200 OK: Full PhotoDetailDto object containing photo details.<br/>
        /// 404 Not Found: If the photo does not exist or does not belong to the specified user (returns null data).
        /// </returns>
        /// <response code="404">Photo not found (data is null)</response>
        [ProducesResponseType(typeof(PhotoDetailDto), 200)] 
        [HttpGet("{photoId}")]
        public async Task<IActionResult> GetPhotoAsync(Guid photoId, [FromQuery] string userId)
        {
            var result = await _photoService.GetPhotoByIdAsync(userId, photoId);
            return StatusCode(result.StatusCode, result.Data);
        }
    }
}