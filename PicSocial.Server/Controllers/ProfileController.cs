using System.Net;
using System.Net.WebSockets;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models;
using PicSocial.Server.Services;
using PicSocial.Server.Controllers;
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
            
            var profileUser = await _profileService.GetProfileAsync(currentUser.Id, userId);
            if(profileUser == null)
                return NotFound(new {message = "User not found"});

            return Ok(profileUser);
        }

      

        [HttpGet("me")]
        public async Task<IActionResult> GetMyProfile()
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();
            var userDto = new UserProfileDto
            {
                UserName = currentUser.UserName!,
                FirstName = currentUser.FirstName,
                Bio = currentUser.Bio,
                AvatarUrl = currentUser.AvatarUrl,
                CoverPhotoUrl = currentUser.CoverPhotoUrl
            };
           return Ok(userDto);
        }
        
        // PUT api/profile
        [HttpPut]
        public async Task<IActionResult> UpdateMyProfile([FromBody] UpdateProfileDto updateProfileDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();
            //Cập nhật thông tin người dùng
            //Cập nhật theo từng trường nếu nó không null hoặc rỗng
            if (!string.IsNullOrWhiteSpace(updateProfileDto.FirstName))
                currentUser.FirstName = updateProfileDto.FirstName;

            if (!string.IsNullOrWhiteSpace(updateProfileDto.Bio))
                currentUser.Bio = updateProfileDto.Bio;

            var result = await _userManager.UpdateAsync(currentUser);
            if (!result.Succeeded)
                return BadRequest(result.Errors);

            return Ok(new {message ="Profile updated successfully" });
        }
    }
}