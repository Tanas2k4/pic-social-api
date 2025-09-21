using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ShareController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ApplicationDbContext _context;

        public ShareController(UserManager<ApplicationUser> userManager, ApplicationDbContext context)
        {
            _userManager = userManager;
            _context = context;
        }

        //POST api/share/{postId}
        [HttpPost("{postId}")]
        public async Task<IActionResult> SharePost(Guid postId, [FromForm] ShareDto shareDto)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return NotFound();

            var post = await _context.Posts
                .Include(p => p.User)
                .Include(p => p.Photos)
                .FirstOrDefaultAsync(p => p.PostId == postId);
            if (post == null)
                return BadRequest();

            var share = new Share
            {
                PostId = postId,
                UserId = user.Id,
                Caption = shareDto.Caption,
                SharePlatform = shareDto.SharePlatform ?? "Internal",
                CreatedDate = DateTimeOffset.Now
            };

            _context.Shares.Add(share);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Post Shared",
                share = new
                {
                    share.PostId,
                    ShareUserName = user.UserName,

                    share.Caption,
                    share.SharePlatform,
                    post = new
                    {
                        post.User.UserName,
                        photo = post.Photos.Select(p => new
                        {
                            originalFileUrl = p.OriginalFileUrl,
                        })
                    },
                    share.CreatedDate
                }            
            });
        }
    }
}