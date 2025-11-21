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
    public class ShareController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IShareService _service;

        public ShareController(UserManager<ApplicationUser> userManager, ApplicationDbContext context, IShareService service)
        {
            _userManager = userManager;
            _service = service;
        }

        //POST api/share/{postId}
        [HttpPost("{postId}")]
        public async Task<IActionResult> SharePost(Guid postId, [FromForm] ShareDto shareDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized(new {message = "You don't have permission" });

            var result = await _service.SharePostAsync(postId, currentUser.Id,  shareDto);
            if(result == null){
                return NotFound(new { message = "Post not found"});}
            return Ok(result);
        }

        //DELETE api/share/{shareId}?post={postId}
        [HttpDelete("{shareId}")]
        public async Task<IActionResult> DeleteSharePost([FromQuery] Guid postId, Guid shareId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _service.DeleteSharePostAsync(postId, shareId, currentUser.Id);
            
            return StatusCode(result.StatusCode, new { message = result.Message });
        }
    }
}