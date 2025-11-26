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
    [Authorize] //Chỉ cho phép người dùng đã xác thực truy cập
    public class ProfileController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IProfileService _profileService; 
        public ProfileController(UserManager<ApplicationUser> userManager, IProfileService profileService)
        {
            _userManager = userManager;
            _profileService = profileService;
        }

        //GET api/profile/{userId}
        [HttpGet("{userId}")]
        public async Task<IActionResult> GetProfileById(string userId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();
            
            var result = await _profileService.GetProfileByIdAsync(currentUser.Id, userId);
            return StatusCode(result.StatusCode, result.Data);
        }

        // GET api/profile/me
        [HttpGet("me")]
        public async Task<IActionResult> GetMyProfile()
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();
            
            var result = await _profileService.GetMyProfileAsync(currentUser.Id);

            return StatusCode(result.StatusCode, result.Data);
        }
        
        // PUT api/profile
        [HttpPut]
        public async Task<IActionResult> UpdateMyProfile([FromBody] ProfileUpdateDto updateProfileDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            //Cập nhật thông tin người dùng
            //Cập nhật theo từng trường nếu nó không null hoặc rỗng
            var result = await _profileService.UpdateMyProfileAsync(currentUser.Id, updateProfileDto);

            return StatusCode(result.StatusCode, result.Data);
        }
    }
}