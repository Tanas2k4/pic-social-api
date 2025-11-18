using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ReactionController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ApplicationDbContext _context;
        public ReactionController(UserManager<ApplicationUser> userManager, ApplicationDbContext context)
        {
            _userManager = userManager;
            _context = context;
        }


        //POST api/reaction/
        [HttpPost("{postId}")]
        public async Task<IActionResult> ReactionPost(Guid postId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var post = await _context.Posts
                .FirstOrDefaultAsync(p => p.PostId == postId);
            if (post == null)
                return NotFound();

            var reaction = await _context.Reactions
                .FirstOrDefaultAsync(r => r.PostId == postId && r.UserId == currentUser.Id);

            if (reaction != null)
            {
                _context.Reactions.Remove(reaction);
                post.ReactionCount--;
                await _context.SaveChangesAsync();
                return Ok(new {message = "unLiked"});
            }
            else
            {
                var newReaction = new Reaction
                {
                    PostId = postId,
                    UserId = currentUser.Id,
                    CreatedDate = DateTimeOffset.Now
                };
                _context.Reactions.Add(newReaction);

                post.ReactionCount++; //Tăng số lượng lượt thích trong Reaction
                await _context.SaveChangesAsync();  
                return Ok(new { message = "liked"});
            }               
        }  
    }
}