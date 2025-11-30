using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.Models;
using PicSocial.Server.DTOs.PostsDto;
using PicSocial.Server.Services.Interfaces;
namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PostController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IPostService _postService;
        
        public PostController( UserManager<ApplicationUser> userManager, IPostService postService)
        {
            _userManager = userManager;
            _postService = postService;
        }

        //POST api/post
        [HttpPost]
        public async Task<IActionResult> UploadPhoto([FromForm] string title, [FromForm] List<IFormFile> files, [FromForm] Guid? licenseId)
        {       
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();
            
            var result = await _postService.UploadPhotoAsync(currentUser.Id, title, files, licenseId);
            return StatusCode(result.StatusCode, result.Data);
        }

        //DELETE api/post/delete/{postId}
        [HttpDelete("{postId}")]
        public async Task<IActionResult> DeletePost(Guid postId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();
            
            var result = await _postService.DeletePostAsync(postId, currentUser.Id);
            return StatusCode(result.StatusCode, new { message = result.Message });
        }

        //PUT api/post/update/{postId}
        [HttpPatch("{postId}")]
        public async Task<IActionResult> UpdatePost(Guid postId, [FromForm] PostUpdateDto updatePostDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _postService.UpdatePostAsync(postId, currentUser.Id, updatePostDto.Title, updatePostDto.LicenseId);
            return StatusCode(result.StatusCode, result.Data);
        }

        //GET api/post/{userId} - Xem tat ca bai dang cua user
        [HttpGet("{userId}")]
        public async Task<IActionResult> GetPostsByUser(string userId)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
                return NotFound("User not found.");

            var results = await _postService.GetPostsByUserAsync(userId);
            return StatusCode(results.StatusCode, results.Data);
        }

        //GET api/post/view/{postId}
        [HttpGet("view/{postId}")]
        public async Task<IActionResult> GetPost(Guid postId)
        {
            var result = await _postService.GetPostByIdAsync(postId);
            return StatusCode(result.StatusCode, result.Data);
        }
    }
}   
