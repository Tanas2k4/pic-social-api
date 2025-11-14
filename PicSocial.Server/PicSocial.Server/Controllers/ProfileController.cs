using System.Net;
using System.Net.WebSockets;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models;
using PicSocial.Server.Services;

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

        //GET api/profile/{userId}
        [HttpGet("{userId}")]
        public async Task<ActionResult<UserProfileDto>> GetProfileById(string userId)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            //Kiểm tra có phải là người lạ hay người đã follow - sử dụng if/else để trả về thông tin phù hợp


            //Lấy thông tin người dùng từ cơ sở dữ liệu dựa trên userId
            var targetUser = await _userManager.FindByIdAsync(userId.ToString());
            if (targetUser == null)
                return NotFound();

            return new UserProfileDto
            {
                UserName = targetUser.UserName!,
                FirstName = targetUser.FirstName,
                Bio = targetUser.Bio,
                AvatarUrl = targetUser.AvatarUrl, //default avatar
                CoverPhotoUrl = targetUser.CoverPhotoUrl
            };
        }

        // GET api/profile/me
        [HttpGet("me")]
        public async Task<ActionResult<UserProfileDto>> GetMyProfile()
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