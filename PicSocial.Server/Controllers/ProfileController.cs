using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs.ProfilesDto;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] // Chỉ cho phép người dùng đã xác thực truy cập
    public class ProfileController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IProfileService _profileService;

        public ProfileController(UserManager<ApplicationUser> userManager, IProfileService profileService)
        {
            _userManager = userManager;
            _profileService = profileService;
        }

        /// <summary>
        /// Retrieves the public profile of another user.
        /// </summary>
        /// <param name="userId">The ID of the user whose profile to view.</param>
        /// <returns>
        /// 200 OK: ProfileUserDto containing basic public information (UserName, FirstName, Bio, AvatarUrl, CoverPhotoUrl, FollowersCount, FollowingCount).<br/>
        /// If the current user is following the target user, the Location field is also included.<br/>
        /// 401 Unauthorized: If not authenticated.<br/>
        /// 404 Not Found: If the target user does not exist.
        /// </returns>
        /// <response code="200">Returns ProfileUserDto (Location included only if following)</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="404">user not found</response>
        [HttpGet("{userId}")]
        [ProducesResponseType(typeof(ProfileUserDto), 200)]
        public async Task<IActionResult> GetProfileById(string userId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _profileService.GetProfileByIdAsync(currentUser.Id, userId);
            return StatusCode(result.StatusCode, result.Data);
        }

        /// <summary>
        /// Retrieves the authenticated user's own full profile.
        /// </summary>
        /// <returns>
        /// 200 OK: ProfileUserDto containing all profile fields, including Location.<br/>
        /// 401 Unauthorized: If not authenticated.<br/>
        /// 404 Not Found: If the current user does not exist (unlikely under normal circumstances).
        /// </returns>
        /// <response code="200">Returns ProfileUserDto with full information including Location</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="404">User not found</response>
        [HttpGet("me")]
        [ProducesResponseType(typeof(ProfileUserDto), 200)]
        public async Task<IActionResult> GetMyProfile()
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _profileService.GetMyProfileAsync(currentUser.Id);
            return StatusCode(result.StatusCode, result.Data);
        }

        /// <summary>
        /// Updates the authenticated user's own profile information.
        /// Only provided fields will be updated (FirstName, Bio, Location).
        /// </summary>
        /// <param name="updateProfileDto">DTO containing optional fields to update.</param>
        /// <returns>
        /// 200 OK: Updated ProfileUserDto reflecting the new profile data (including Location).<br/>
        /// 401 Unauthorized: If not authenticated.<br/>
        /// 404 Not Found: If the current user does not exist.
        /// </returns>
        /// <response code="200">Returns updated ProfileUserDto</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="404">User not found</response>
        [HttpPatch]
        [ProducesResponseType(typeof(ProfileUserDto), 200)]
        public async Task<IActionResult> UpdateMyProfile([FromBody] ProfileUpdateDto updateProfileDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _profileService.UpdateMyProfileAsync(currentUser.Id, updateProfileDto);
            return StatusCode(result.StatusCode, result.Data);
        }
    }
}