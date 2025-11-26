using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs.FollowsDto;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;


namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class FollowController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ApplicationDbContext _context;
        private readonly IFollowService _service;
        public FollowController(UserManager<ApplicationUser> userManager, ApplicationDbContext context, IFollowService service)
        {
            _userManager = userManager;
            _context = context;
            _service = service;
        }

        //GET api/follow/isfollowing/{id} //id là id của người mà bạn muốn kiểm tra xem có đang theo dõi không
        [HttpGet("isFollowing/{userId}")]
        public async Task<IActionResult> IsFollowing(string userId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var isFollowing = await _service.IsFollowingAsync(currentUser.Id, userId);

            return Ok(new { message = isFollowing });
        }

        // POST api/follow //id là id của người mà bạn muốn follow
        [HttpPost]
        public async Task<IActionResult> FollowUser([FromBody] FollowDto followDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _service.FollowUserAsync(currentUser.Id, followDto);
            
            return StatusCode(result.StatusCode, new { message = result.Message });
        }

        // DELETE api/follow/{id} //id là id của người mà bạn muốn unfollow
        [HttpDelete("{userId}")]
        public async Task<IActionResult> UnfollowUser(string userId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _service.UnfollowUserAsync(currentUser.Id, userId);
            
            return StatusCode(result.StatusCode, new { message = result.Message});
        }

        // GET api/follow/followers/{id} //id là id của người dùng mà bạn muốn lấy danh sách người theo dõi
        [HttpGet("followers/{id}")]
        public async Task<IActionResult> GetFollowers(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
                return NotFound("User not found.");

            var result = await _service.GetFollowerAsync(id);
            return Ok(result);
        }

        // GET api/follow/following/{id} //id là id của người dùng mà bạn muốn lấy danh sách người mà họ đang theo dõi
        [HttpGet("following/{id}")]
        public async Task<IActionResult> GetFollowing(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
                return NotFound("User not found.");

            var result = await _service.GetFollowingAsync(id);
            return Ok(result);
        }
    }
}