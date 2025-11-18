using System.Xml;
using Azure.Messaging;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;
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

        // POST api/follow //id là id của người mà bạn muốn follow
        [HttpPost]
        public async Task<IActionResult> FollowUser([FromBody] FollowDto followDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            if (currentUser.Id == followDto.Id)
                return BadRequest("You cannot follow yourself.");

            var userToFollow = await _userManager.FindByIdAsync(followDto.Id);
            if (userToFollow == null)
                return NotFound("User not found.");
            var existingFollow = _context.Follows.FirstOrDefault(f => f.FollowerId == currentUser.Id && f.FollowedId == followDto.Id);
            if (existingFollow != null)
                return BadRequest("You are already following this user.");

            //Tạo một thực thể Follow mới
            var follow = new Follow
            {
                FollowerId = currentUser.Id,
                FollowedId = followDto.Id,
                CreatedDate = DateTimeOffset.Now
            };
            _context.Follows.Add(follow);

            currentUser.FollowersCount++;
            userToFollow.FollowingCount++;
            
            _context.Users.Update(currentUser);
            _context.Users.Update(userToFollow);

            await _context.SaveChangesAsync();
            return Ok("Successfully followed the user.");
        }

        //GET api/follow/isfollowing/{id} //id là id của người mà bạn muốn kiểm tra xem có đang theo dõi không
        [HttpGet("isFollowing/{userId}")]
        public async Task<IActionResult> IsFollowing(string userId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var isFollowing = await _service.IsFollowingAsync(currentUser.Id, userId);

            return Ok( new { message = isFollowing});
        }

        // DELETE api/follow/{id} //id là id của người mà bạn muốn unfollow
        [HttpDelete("{userId}")]
        public async Task<IActionResult> UnfollowUser(string userId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            //Kiểm tra xem người dùng có đang theo dõi người này không
            var follow = await _context.Follows
                .FirstOrDefaultAsync(f => f.FollowerId == currentUser.Id && f.FollowedId == userId);
            if (follow == null)
                return NotFound("You are not following this user.");
            var userToUnfollow = await _userManager.FindByIdAsync(userId);
            if (userToUnfollow == null)
                return NotFound("User not found");

            _context.Follows.Remove(follow);

            currentUser.FollowersCount--;
            userToUnfollow.FollowingCount--;

            _context.Users.Update(currentUser);
            _context.Users.Update(userToUnfollow);

            await _context.SaveChangesAsync();
            return Ok("Successfully unfollowed the user.");
        }

        // GET api/follow/followers/{id} //id là id của người dùng mà bạn muốn lấy danh sách người theo dõi
        [HttpGet("followers/{id}")]
        public async Task<IActionResult> GetFollowers(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
                return NotFound("User not found.");
            //trả về số lượng người đang theo dõi mình
            var followerCount = _context.Follows.Count(f => f.FollowedId == id);

            //trả về danh sách người đang theo dõi mình
            var followers = await _context.Follows
                .Where(f => f.FollowedId == id)
                .Select(f => new { f.FollowerId, f.Follower.UserName, f.Follower.AvatarUrl })
                .ToListAsync();

            return Ok(new
            {
                FollowerCount = followerCount,
                Followers = followers
            });
        }

        // GET api/follow/following/{id} //id là id của người dùng mà bạn muốn lấy danh sách người mà họ đang theo dõi
        [HttpGet("following/{id}")]
        public async Task<IActionResult> GetFollowing(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
                return NotFound("User not found.");

            //trả về số lượng người mà họ đang theo dõi
            var followingCount = _context.Follows.Count(f => f.FollowerId == id);

            //trả về danh sách người mà họ đang theo dõi
            var following = await _context.Follows
                .Where(f => f.FollowerId == id)
                .Select(f => new { f.FollowedId, f.Followed.UserName, f.Followed.AvatarUrl })
                .ToListAsync();

            return Ok(new
            {
                FollowingCount = followingCount,
                Following = following
            });
        }
    }
}