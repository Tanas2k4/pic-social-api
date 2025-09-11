using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] //Chỉ cho phép người dùng đã xác thực truy cập
    public class ProfileController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        public ProfileController(UserManager<ApplicationUser> userManager)
        {
            _userManager = userManager;
        }

        //GET api/profile/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<UserProfileDto>> GetProfileById()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            return new UserProfileDto
            {
                UserName = user.UserName!,
                FirstName = user.FirstName,
                Bio = user.Bio,
                AvatarUrl = user.AvatarUrl, //default avatar
                CoverPhotoUrl = user.CoverPhotoUrl
            };
        }

        // PUT api/profile/update
        [HttpPut("update")]
        public async Task<IActionResult> UpdateMyProfile([FromBody] UpdateProfileDto updateProfileDto)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();
            
            //Cập nhật thông tin người dùng
            //Cập nhật theo từng trường nếu nó không null hoặc rỗng
            if (!string.IsNullOrWhiteSpace(updateProfileDto.FirstName))
                user.FirstName = updateProfileDto.FirstName;

            if(!string.IsNullOrWhiteSpace(updateProfileDto.Bio))
                user.Bio = updateProfileDto.Bio;

            if (!string.IsNullOrWhiteSpace(updateProfileDto.AvatarUrl))
                user.AvatarUrl = updateProfileDto.AvatarUrl;

            if (!string.IsNullOrWhiteSpace(updateProfileDto.CoverPhotoUrl))
                user.CoverPhotoUrl = updateProfileDto.CoverPhotoUrl;

            var result = await _userManager.UpdateAsync(user);
            if (!result.Succeeded)
                return BadRequest(result.Errors);

            return Ok(new {message ="Profile updated successfully" });
        }
    }
}